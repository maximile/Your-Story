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
#import "StreetLight.h"
#import "Rocket.h"
#import "Music.h"

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

static int characterHitStreetLight(cpArbiter *arb, cpSpace *space, Game *game) {
	CP_ARBITER_GET_BODIES(arb, characterBody, streetLightBody);	
	CP_ARBITER_GET_SHAPES(arb, characterShape, streetLightShape);	
	Character *character = characterBody->data;
	StreetLight *streetLight = streetLightShape->data;
	int streetLightIndex = [game.streetLights indexOfObject:streetLight];
	character.battery = 1.0;
	
	[game saveState];
	[game.stateDict setValue:[NSNumber numberWithInt:streetLightIndex] forKey:@"checkpoint"];
	
	return FALSE;
}

@implementation Game

@synthesize mode, currentRoom, editingLayer, cursorLoc, player, space, fixedTime, stateDict, coinCount, streetLights;

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
	
	Font *timeFont = [Font fontNamed:@"Geneva9"];
	pixelCoords timeCoords = pixelCoordsMake(CANVAS_SIZE.width/2, -1);
	timeLabel = [[Message alloc] initWithPosition:timeCoords font:timeFont string:@"0:00.0"];
	timeLabel.alignment = NSCenterTextAlignment;
	timeLabel.screenSpace = YES;
	
	space = cpSpaceNew();
	cpSpaceSetGravity(space, cpv(0, -GRAVITY));
	cpSpaceSetCollisionSlop(space, COLLISION_SLOP);
	cpSpaceSetEnableContactGraph(space, TRUE);
	
	// add collision handlers
	cpSpaceAddCollisionHandler(space, [Character class], [Jumper class], NULL, (cpCollisionPreSolveFunc)characterHitEnemy, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [Character class], [Parasprite class], NULL, (cpCollisionPreSolveFunc)characterHitEnemy, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [Character class], [Pickup class], NULL, (cpCollisionPreSolveFunc)characterHitPickup, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [Character class], [StreetLight class], NULL, (cpCollisionPreSolveFunc)characterHitStreetLight, NULL, NULL, self);
	
	uiMap = [TileMap mapNamed:@"UI"];
	lightmapCanvas = [(FBO *)[FBO alloc] initWithSize:CANVAS_SIZE];

	NSString *connectionsPath = [[NSBundle mainBundle] pathForResource:@"Connections" ofType:@"plist"];
	connections = [NSArray arrayWithContentsOfFile:connectionsPath];
	NSString *startingRoomName = [[connections objectAtIndex:0] valueForKey:@"Name"];
	// [self setCurrentRoom:[[Room alloc] initWithName:startingRoomName]];
	
	stateDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		[NSNumber numberWithBool:NO], @"doubleJump",
		[NSNumber numberWithBool:NO], @"shotgun",
		[NSNumber numberWithInt:8], @"health",
		[NSNumber numberWithInt:0], @"coins",
		[NSNumber numberWithInt:-1], @"checkpoint",
		startingRoomName, @"room",
		[NSNumber numberWithInt:NOWHERE], @"spawn",
		@"Character", @"playerClass",
	nil];
	
	
	Texture *uiTexture = [Texture textureNamed:@"UI"];
	actionPrompt1Sprite = [[Sprite alloc] initWithTexture:uiTexture texRect:pixelRectMake(0, 16, 16, 16)];
	actionPrompt2Sprite = [[Sprite alloc] initWithTexture:uiTexture texRect:pixelRectMake(0, 32, 16, 16)];
	
	[self restoreState];
	
	// transition stuff
	transition = 1.0;
	transitionTilesCount = 6;
	transitionTiles = calloc(transitionTilesCount, sizeof(mapCoords));
	transitionTiles[0] = mapCoordsMake(-1, -1);
	transitionTiles[1] = mapCoordsMake(1, 0);
	transitionTiles[2] = mapCoordsMake(2, 0);
	transitionTiles[3] = mapCoordsMake(3, 0);
	transitionTiles[4] = mapCoordsMake(1, 1);
	transitionTiles[5] = mapCoordsMake(2, 1);
	NSDictionary *transitionLayerDict = [NSDictionary dictionaryWithObjectsAndKeys:
		@"UI", @"Map",
	nil];
	mapSize transitionLayerSize = mapSizeMake(CANVAS_SIZE.width / TILE_SIZE + 1, CANVAS_SIZE.height / TILE_SIZE + 1);
	transitionLayer = [[Layer alloc] initWithDictionary:transitionLayerDict size:transitionLayerSize];
	
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

- (void)saveState {
	[stateDict setValue:NSStringFromClass([player class]) forKey:@"playerClass"];
	[stateDict setValue:[NSNumber numberWithInt:coinCount] forKey:@"coins"];
	[stateDict setValue:currentRoom.name forKey:@"room"];
	[stateDict setValue:[NSNumber numberWithInt:-1] forKey:@"checkpoint"];
	
	// save player health, abilities etc.
	[player updateStateDict:stateDict];
}

- (void)restoreState {
	Room *room = [[Room alloc] initWithName:[stateDict valueForKey:@"room"]];
	directionMask edge = [[stateDict valueForKey:@"spawn"] intValue];
	coinCount = [[stateDict valueForKey:@"coins"] intValue];
	[self setCurrentRoom:room fromEdge:edge];
	
	int checkpointIndex = [[stateDict valueForKey:@"checkpoint"] intValue];
	if (checkpointIndex > -1) {
		StreetLight *light = [streetLights objectAtIndex:checkpointIndex];
		cpBodySetPos(player.body, cpv(light.startingPosition.x, light.startingPosition.y));
	} 
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
	streetLights = [NSMutableArray array];
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
		if ([item isKindOfClass:[StreetLight class]]) {
			NSLog(@"YO");
			[streetLights addObject:item];
		}
		if ([item isKindOfClass:[Door class]]) {
			door = (Door *)item;
		}
		if ([item isKindOfClass:[Rocket class]]) {
			rocket = (Rocket *)item;
		}
	}
	
	// find the most appropriate spawn point and start the player there
	Spawn *theSpawn = [Spawn getSpawnForEdge:edge spawns:spawns];
	Class playerClass = NSClassFromString([stateDict valueForKey:@"playerClass"]);
	player = [[playerClass alloc] initWithPosition:theSpawn.startingPosition state:stateDict];
	[self addItem:player];
	[self addAndRemoveItems];
	
	if ([player isKindOfClass:[Rocket class]]) {
		rocket = (Rocket *)player;
	}
	
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
	
	// set music
	NSString *newMusicName = currentRoom.musicName;
	if (![newMusicName isEqualToString:musicName]) {
		[music stop];
		musicName = newMusicName;
		music = [[Music alloc] initWithFilename:musicName];
		[music play];
	}
}

-(void)updateStep {	
	// update physics and let objects update
	for (Item *item in items) {
		[item update:self];
	}
	cpSpaceStep(space, FIXED_DT);
	[self addAndRemoveItems];
	
	timeTaken += FIXED_DT;
	int minutes = (int)timeTaken / 60;
	float seconds = timeTaken - (minutes * 60);
	timeLabel.string = [NSString stringWithFormat:@"%i:%04.1f", minutes, seconds];
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
	if (player == nil) transition += 0.02;
	else transition -= 0.02;
	if (transition >= 1.0) {
		[self restoreState];
	}
	if (transition <= 0.0) {
		transition = 0.0;
	}
	
	if (player == nil) return;
	
	// out of the room bounds? Go to another room or die
	pixelCoords pos = player.pixelPosition;
	directionMask outside = NOWHERE;
	if (pos.x < 0) outside |= LEFT;
	if (pos.x > (currentRoom.size.width) * TILE_SIZE) outside |= RIGHT;
	if (pos.y < 0) outside |= DOWN;
	if (pos.y > (currentRoom.size.height) * TILE_SIZE) outside |= UP;
	if (outside) {
		NSString *nextRoomName = [self roomNameInDirection:outside];
		if ([nextRoomName isEqualToString:@"Win"]){
			// finished the game
			completionTime = timeTaken;
			timeLabel = nil;
			int minutes = (int)timeTaken / 60;
			float seconds = timeTaken - (minutes * 60);
			NSString *completionTimeString = [NSString stringWithFormat:@"%i:%04.1f", minutes, seconds];
			NSString *completionLabelMessage1 = [NSString stringWithFormat:@"Congratulations! You finished in %@!", completionTimeString];
			NSString *completionLabelMessage2 = @"Try collecting all the coins for a better ending!";
			NSString *completionLabelMessage3 = @"Thanks for playing!";
			if (coinCount == 8) {
				nextRoomName = @"SuperWin";
				completionLabelMessage2 = @"You collected all the coins! You’re awesome!";
			}
			pixelCoords completionLabelPos1 = pixelCoordsMake(CANVAS_SIZE.width/2, CANVAS_SIZE.height - 30);
			pixelCoords completionLabelPos2 = pixelCoordsMake(CANVAS_SIZE.width/2, CANVAS_SIZE.height - 50);
			pixelCoords completionLabelPos3 = pixelCoordsMake(CANVAS_SIZE.width/2, CANVAS_SIZE.height - 80);
			Font *completionLabelFont1 = [Font fontNamed:@"Geneva9"];
			Font *completionLabelFont2 = [Font fontNamed:@"Chicago12"];
			completionLabel1 = [[Message alloc] initWithPosition:completionLabelPos1 font:completionLabelFont1 string:completionLabelMessage1];
			completionLabel2 = [[Message alloc] initWithPosition:completionLabelPos2 font:completionLabelFont1 string:completionLabelMessage2];
			completionLabel3 = [[Message alloc] initWithPosition:completionLabelPos3 font:completionLabelFont2 string:completionLabelMessage3];
			completionLabel1.alignment = NSCenterTextAlignment;
			completionLabel1.screenSpace = YES;
			completionLabel2.alignment = NSCenterTextAlignment;
			completionLabel2.screenSpace = YES;
			completionLabel3.alignment = NSCenterTextAlignment;
			completionLabel3.screenSpace = YES;
			
		}
		if (nextRoomName != nil) {
			directionMask startingEdge = NOWHERE;
			if (outside & RIGHT) startingEdge |= LEFT;
			if (outside & LEFT) startingEdge |= RIGHT;
			if (outside & UP) startingEdge |= DOWN;
			if (outside & DOWN) startingEdge |= UP;
			
			[self saveState];
			
			[stateDict setValue:[NSNumber numberWithInt:startingEdge] forKey:@"spawn"];
			[stateDict setValue:nextRoomName forKey:@"room"];
			
			[self removeItem:player];
			[self addAndRemoveItems];
			player = nil;			
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
	// if (![player isKindOfClass:[Character class]]) action = NO;
	if (wasPressingAction) action = NO;
	wasPressingAction = (downKey || upKey);
	
	BOOL nearDoor = NO;
	if (door && cpvdist(player.position, cpv(door.startingPosition.x, door.startingPosition.y)) < 10.0)
		nearDoor = YES;
	if (nearDoor && action) {
		NSString *nextRoomName = [self roomNameInDirection:NOWHERE];

		[self saveState];
		
		[stateDict setValue:[NSNumber numberWithInt:NOWHERE] forKey:@"spawn"];
		[stateDict setValue:nextRoomName forKey:@"room"];
		
		[self removeItem:player];
		[self addAndRemoveItems];
		player = nil;
		door.open = YES;
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
	
	BOOL nearRocket = NO;
	if (rocket != nil && [player isKindOfClass:[Character class]]) {
		float rocketDist = cpvdist(player.position, cpv(rocket.position.x, rocket.position.y - 24.0));
		if (rocketDist < 28.0) {
			nearRocket = YES;
		}
	}
	
	if ([player isKindOfClass:[Character class]]) {
		if (action && nearRocket) {
			[player updateStateDict:stateDict];
			[self removeItem:player];
			player = rocket;
		}
	}
	else {
		if (action && downKey && [player isKindOfClass:[Rocket class]]) {
			pixelCoords exitPos = pixelCoordsMake(player.pixelPosition.x - 19, player.pixelPosition.y - 24);
			Player *newPlayer = [[Character alloc] initWithPosition:exitPos state:stateDict];
			newPlayer.body->v = player.body->v;
			[self addItem:newPlayer];
			player = newPlayer;
		}
	}
	
	// if (action && nearRocket && [player isKindOfClass:[Character class]]) {
	// 	[player updateStateDict:stateDict];
	// 	[self removeItem:player];
	// 	player = rocket;
	// }
	// if (action && downKey && [player isKindOfClass:[Rocket class]]) {
	// 	NSLog(@"HERE YO");
	// 	Player *newPlayer = [[Character alloc] initWithPosition:player.pixelPosition state:stateDict];
	// 	newPlayer.body->v = player.body->v;
	// 	[self addItem:newPlayer];
	// 	player = newPlayer;
	// }
	
	// draw indicator to say that you can press action
	if (nearDoor || nearFriend || nearRocket) {
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

- (NSString *)roomNameInDirection:(directionMask)direction {
	NSString *directionKey = nil;
	if (direction & LEFT) directionKey = @"Left";
	if (direction & RIGHT) directionKey = @"Right";
	if (direction & UP) directionKey = @"Up";
	if (direction & DOWN) directionKey = @"Down";
	if (direction == NOWHERE) directionKey = @"Door";
		
	return [connectionDict valueForKey:directionKey];
}

@end
