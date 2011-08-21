#import "Game.h"
#import "Constants.h"
#import "Game+Editor.h"
#import "Game+Items.h"
#import "Game+Input.h"
#import "Game+Drawing.h"
#import "Character.h"
#import "ItemLayer.h"
#import "Item.h"
#import "Jumper.h"

static int characterHitJumper(cpArbiter *arb, cpSpace *space, void *data) {
	CP_ARBITER_GET_BODIES(arb, characterBody, jumperBody);
	Character *character = characterBody->data;
	Jumper *jumper = jumperBody->data;
	return [character hitJumper:jumper arbiter:arb];
}

static int damageAreaHitJumper(cpArbiter *arb, cpSpace *space, void *data) {
	CP_ARBITER_GET_BODIES(arb, characterBody, jumperBody);
	Jumper *jumper = jumperBody->data;
	Game *game = data;
	[jumper shotFrom:game.player.position];
	return 0;
}

@implementation Game

@synthesize mode, currentRoom, editingLayer, cursorLoc, player;

- (id)init {
	if ([super init] == nil) {
		return nil;
	}
	
	items = [NSMutableArray array];
	itemsToRemove = [NSMutableArray array];
	itemsToAdd = [NSMutableArray array];
	
	space = cpSpaceNew();
	cpSpaceSetGravity(space, cpv(0, -GRAVITY));
	cpSpaceSetCollisionSlop(space, COLLISION_SLOP);
	cpSpaceSetEnableContactGraph(space, TRUE);
	
	// add collision handlers
	cpSpaceAddCollisionHandler(space, [Character class], [Jumper class], NULL, characterHitJumper, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, [DamageArea class], [Jumper class], NULL, damageAreaHitJumper, NULL, NULL, self);
	
	[self setCurrentRoom:[[Room alloc] initWithName:@"Another"]];
		
	uiMap = [TileMap mapNamed:@"UI"];
	
	return self;
}


- (void)draw {
	switch (mode) {
		case GAME_MODE:
			[self drawGame];
			break;
		case EDITOR_MODE:
			[self drawEditor];
			break;
		default:
			break;
	}
}

- (void)setMode:(gameMode)newMode {
	if (mode == newMode) return;
	mode = newMode;
	if (newMode == EDITOR_MODE) {
		editorFocus = player.position;
		[self setEditingLayer:currentRoom.mainLayer];
	}
	if (newMode == GAME_MODE) {
		[currentRoom.mainLayer removeFromSpace:space];
		[currentRoom.mainLayer addToSpace:space];
	}
}

- (void)setCurrentRoom:(Room *)newRoom {
	if (currentRoom == newRoom) return;
	[currentRoom.mainLayer removeFromSpace:space];
	currentRoom = newRoom;
	
	// add room collision shapes
	[currentRoom.mainLayer addToSpace:space];
	
	// add items from room
	NSArray *roomItems = [currentRoom.itemLayer items];
	for (Item *item in roomItems) {
		NSLog(@"%@", item);
		[self addItem:item];
		if ([item isKindOfClass:[Player class]]) {
			player = (Player *)item;
		}
	}
	
	[self setEditingLayer:currentRoom.mainLayer];	
}

-(void)updateStep {
	[self addAndRemoveItems];
	
	// update physics and let objects update
	for (Item *item in items) {
		[item update:self];
	}
	
	cpSpaceStep(space, FIXED_DT);
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
	[player setInput:directionInput];
	
	if (spaceKey) {
		[player shoot:space];
	}
	
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


@end
