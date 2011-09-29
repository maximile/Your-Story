#import "Game.h"
#import "Constants.h"
#import "Game+Editor.h"
#import "Game+Items.h"
#import "Game+Input.h"
#import "Game+Drawing.h"
#import "Character.h"
#import "Bullet.h"
#import "ItemLayer.h"
#import "Item.h"
#import "Jumper.h"
#import "Pickup.h"
#import "Spawn.h"
#import "Sound.h"
#import "Door.h"
#import "Message.h"
#import "Friend.h"
#import "Parasprite.h"
#import "Rocket.h"

static int characterHitPickup(cpArbiter *arb, cpSpace *space, Game *game) {
	CP_ARBITER_GET_BODIES(arb, characterBody, pickupBody);
	CP_ARBITER_GET_SHAPES(arb, characterShape, pickupShape);
	Character *character = characterBody->data;
	Item *pickup = pickupShape->data;
	
	return [character hitPickup:pickup arbiter:arb];
}

static int characterHitEnemy(cpArbiter *arb, cpSpace *space, Game *game) {
	CP_ARBITER_GET_BODIES(arb, characterBody, jumperBody);
	Character *character = characterBody->data;
	[character hitEnemy:jumperBody->data arbiter:arb];
	
	return FALSE;
}

@implementation Game

@synthesize mode, currentRoom, editingLayer, cursorLoc, player, space, fixedTime;

static Game *game = nil;
+ (Game *)game {
	return game;
}

- (id)init {
	if ([super init] == nil) {
		return nil;
	}
	
	game = self;
	
	items = [NSMutableArray array];
	itemsToRemove = [NSMutableArray array];
	itemsToAdd = [NSMutableArray array];
	
	space = cpSpaceNew();
	cpSpaceSetGravity(space, cpv(0, -GRAVITY));
	cpSpaceSetCollisionSlop(space, COLLISION_SLOP);
	cpSpaceSetEnableContactGraph(space, TRUE);
	
	// add collision handlers
	cpSpaceAddCollisionHandler(space, [Character class], [Jumper class], NULL, (cpCollisionPreSolveFunc)characterHitEnemy, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [Character class], [Parasprite class], NULL, (cpCollisionPreSolveFunc)characterHitEnemy, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [Character class], [Pickup class], NULL, (cpCollisionPreSolveFunc)characterHitPickup, NULL, NULL, self);
	
	uiMap = [TileMap mapNamed:@"UI"];
	lightmapCanvas = [(FBO *)[FBO alloc] initWithSize:CANVAS_SIZE];

	NSString *connectionsPath = [[NSBundle mainBundle] pathForResource:@"Connections" ofType:@"plist"];
	connections = [NSArray arrayWithContentsOfFile:connectionsPath];
	NSString *startingRoomName = [[connections objectAtIndex:0] valueForKey:@"Name"];
	NSLog(@"%@", startingRoomName);
	[self setCurrentRoom:[[Room alloc] initWithName:startingRoomName]];
	
	Texture *uiTexture = [Texture textureNamed:@"UI"];
	actionPrompt1Sprite = [[Sprite alloc] initWithTexture:uiTexture texRect:pixelRectMake(0, 16, 16, 16)];
	actionPrompt2Sprite = [[Sprite alloc] initWithTexture:uiTexture texRect:pixelRectMake(0, 32, 16, 16)];
	
	return self;
}


- (void)drawOnCanvas:(FBO *)canvas {
	switch (mode) {
		case GAME_MODE:
			[self drawGameOnCanvas:canvas];
			break;
		case EDITOR_MODE:
			[self drawEditorOnCanvas:canvas];
			break;
		default:
			break;
	}
}

- (void)setMode:(gameMode)newMode {
	if (mode == newMode) return;
	mode = newMode;
	if (newMode == EDITOR_MODE) {
		editorFocus = player.pixelPosition;
		[self setEditingLayer:currentRoom.mainLayer];
	}
	if (newMode == GAME_MODE) {
		[currentRoom.mainLayer removeFromSpace:space];
		[currentRoom.mainLayer addToSpace:space];
	}
}

- (void)setCurrentRoom:(Room *)newRoom {
	[self setCurrentRoom:newRoom fromEdge:NOWHERE];
}

- (void)setCurrentRoom:(Room *)newRoom fromEdge:(directionMask)edge {
	// record player velocity
	cpVect oldVelocity = cpvzero;
	if (player != nil)
		oldVelocity = player.body->v;
	
	// clear old room stuff
	for (Item *item in items) {
		[self removeItem:item];
	}
	player = nil;
	door = nil;
	[self addAndRemoveItems];
	[currentRoom.mainLayer removeFromSpace:space];
	
	currentRoom = newRoom;
	
	// add room collision shapes
	[currentRoom.mainLayer addToSpace:space];
	
	// add items from room
	NSArray *roomItems = [currentRoom.itemLayer items];
	NSMutableArray *spawns = [NSMutableArray array];
	friends = [NSMutableArray array];
	for (Item *item in roomItems) {
		[self addItem:item];
		if ([item isKindOfClass:[Spawn class]]) {
			[spawns addObject:item];
		}
		if ([item isKindOfClass:[Friend class]]) {
			[(NSMutableArray *)friends addObject:item];
		}
		if ([item isKindOfClass:[Door class]]) {
			door = (Door *)item;
		}
	}
	
	// find the most appropriate spawn point and start the player there
	Spawn *theSpawn = [Spawn getSpawnForEdge:edge spawns:spawns];
	player = [[Rocket alloc] initWithPosition:theSpawn.startingPosition];
	[self addItem:player];
	[self addAndRemoveItems];
	
	// restore old player velocity
	player.body->v = oldVelocity;
	
	[self setEditingLayer:currentRoom.mainLayer];	
	
	// set current connection dict to store neighbouring rooms
	for (NSDictionary *testConnectionDict in connections) {
		if ([[testConnectionDict valueForKey:@"Name"] isEqualToString:currentRoom.name]) {
			connectionDict = testConnectionDict;
		}
	}
	
	// add room title message
	NSString *title = [connectionDict valueForKey:@"Title"];
	pixelCoords titleLoc = pixelCoordsMake(CANVAS_SIZE.width / 2, 30);
	Font *titleFont = [Font fontNamed:@"Chicago12"];
	Message *titleLabel = [[Message alloc] initWithPosition:titleLoc font:titleFont string:title];
	titleLabel.life = 4.0;
	titleLabel.alignment = NSCenterTextAlignment;
	titleLabel.screenSpace = YES;
	[self addItem:titleLabel];
}

-(void)updateStep {	
	// update physics and let objects update
	for (Item *item in items) {
		[item update:self];
	}
	cpSpaceStep(space, FIXED_DT);
	[self addAndRemoveItems];
}

#import <mach/mach_time.h>
double getDoubleTime(void)
{
	mach_timebase_info_data_t base;
	mach_timebase_info(&base);
	
	return (double)mach_absolute_time()*((double)base.numer/(double)base.denom*1.0e-9);
}

- (void)updateGame {	
	directionMask directionInput = NOWHERE;
	// get keyboard input
	if (upKey) { directionInput |= UP; }
	if (downKey) { directionInput |= DOWN; }
	if (leftKey) { directionInput |= LEFT; }
	if (rightKey) { directionInput |= RIGHT; }
	[player setInput:directionInput jump:zKey shoot:xKey];
	
	if(xKey && !wasPressingX) [player shoot:self];
	wasPressingX = xKey;
	
	drawCollision = tabKey;
	
	double time = getDoubleTime();
	double dt = time - lastTime;
	lastTime = time;
	
	accumulator = MIN(accumulator + dt, FIXED_DT*MAX_FRAMESKIP);
	while(accumulator > FIXED_DT){
		[self updateStep];
		accumulator -= FIXED_DT;
		fixedTime += FIXED_DT;
	}
	
	// dead? restart the room
	if (player == nil) [self setCurrentRoom:currentRoom];
	
	// out of the room bounds? Go to another room or die
	pixelCoords pos = player.pixelPosition;
	directionMask outside = NOWHERE;
	if (pos.x < 0) outside |= LEFT;
	if (pos.x > (currentRoom.size.width) * TILE_SIZE) outside |= RIGHT;
	if (pos.y < 0) outside |= DOWN;
	if (pos.y > (currentRoom.size.height) * TILE_SIZE) outside |= UP;
	if (outside) {
		Room *nextRoom = [self roomInDirection:outside];
		if (nextRoom != nil) {
			directionMask startingEdge = NOWHERE;
			if (outside & RIGHT) startingEdge |= LEFT;
			if (outside & LEFT) startingEdge |= RIGHT;
			if (outside & UP) startingEdge |= DOWN;
			if (outside & DOWN) startingEdge |= UP;
			[self setCurrentRoom:nextRoom fromEdge:startingEdge];
			// TODO: move player to the corresponding entrance
		}
		else {
			// fell off the bottom and no downwards room? die
			if (outside & DOWN) {
				[self removeItem:player];
				[self addAndRemoveItems];
				player = nil;
			}
		}
	}
	
	// interact with items
	BOOL action = (downKey || upKey);
	if (wasPressingAction) action = NO;
	wasPressingAction = (downKey || upKey);
	
	
	BOOL nearDoor = NO;
	if (door && cpvdist(player.position, cpv(door.startingPosition.x, door.startingPosition.y)) < 10.0)
		nearDoor = YES;
	if (nearDoor && action) {
		// pressing down or up and there is a door in the room
		Room *nextRoom = [self roomInDirection:NOWHERE];
		[self setCurrentRoom:nextRoom fromEdge:NOWHERE];
	}
	
	BOOL nearFriend = NO;
	Friend *theFriend = nil;
	for (Friend *friend in friends) {
		float testDist = cpvdist(player.position, cpv(friend.startingPosition.x, friend.startingPosition.y));
		if (testDist < 24.0) {
			// near a friend
			nearFriend = YES;
			theFriend = friend;
		}
	}
	if (action && nearFriend) {
		[theFriend displayMessage:self];
	}
	if (!nearFriend) {
		for (Friend *friend in friends) {
			[friend removeMessage:self];
		}
	}
	
	// draw indicator to say that you can press action
	if (nearDoor || nearFriend) {
		if (cpfsin(fixedTime * 8) > 0)
			[actionPrompt1Sprite drawAt:pixelCoordsMake(player.position.x, player.position.y - 18)];
		else
			[actionPrompt2Sprite drawAt:pixelCoordsMake(player.position.x, player.position.y - 18)];
	}
}

- (void)update {
	switch (mode) {
		case GAME_MODE:
			[self updateGame];
			break;
		case EDITOR_MODE:
			[self updateEditor];
			break;
		default:
			break;
	}
}

- (void)setCurrentRoomFromPath:(NSString *)path {
	self.currentRoom = [[Room alloc] initWithFile:path];
}

- (void)writeCurrentRoomToPath:(NSString *)path {
	[self.currentRoom writeToFile:path];
}


- (Room *)roomInDirection:(directionMask)direction {
	NSString *directionKey = nil;
	if (direction & LEFT) directionKey = @"Left";
	if (direction & RIGHT) directionKey = @"Right";
	if (direction & UP) directionKey = @"Up";
	if (direction & DOWN) directionKey = @"Down";
	if (direction == NOWHERE) directionKey = @"Door";
		
	NSString *newRoomName = [connectionDict valueForKey:directionKey];
	if (newRoomName == nil) return nil;
	return [[Room alloc] initWithName:newRoomName];
}

@end
