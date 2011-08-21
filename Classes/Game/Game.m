#import "Game.h"
#import "Constants.h"
#import "Game+Editor.h"
#import "Game+Items.h"
#import "Game+Input.h"
#import "Character.h"
#import "ItemLayer.h"
#import "Item.h"
#import "ChipmunkDebugDraw.h"
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
	// [player addToSpace:space];
	// player.position = cpv(235, 232);
	
	uiMap = [TileMap mapNamed:@"UI"];
	
	return self;
}

- (mapCoords)cameraTargetForFocus:(cpVect)focus {
	if (currentRoom.mainLayer.size.height * TILE_SIZE <= CANVAS_SIZE.height) {
		// room is shorter than the screen, center it vertically
		focus.y = (currentRoom.mainLayer.size.height * TILE_SIZE) / 2;
	}
	else {
		// clamp focus to height of room
		if (focus.y < CANVAS_SIZE.height / 2) {
			focus.y = CANVAS_SIZE.height / 2;
		}
		else if (focus.y > (currentRoom.mainLayer.size.height * TILE_SIZE) - CANVAS_SIZE.height / 2) {
			focus.y = (currentRoom.mainLayer.size.height * TILE_SIZE) - CANVAS_SIZE.height / 2;
		}
	}

	if (currentRoom.mainLayer.size.width * TILE_SIZE <= CANVAS_SIZE.width) {
		// room is thinner than the screen, center it horizontally
		focus.x = (currentRoom.mainLayer.size.width * TILE_SIZE) / 2;
	}
	else {
		// clamp focus to width of room
		if (focus.x < CANVAS_SIZE.width / 2) {
			focus.x = CANVAS_SIZE.width / 2;
		}
		else if (focus.x > (currentRoom.mainLayer.size.width * TILE_SIZE) - CANVAS_SIZE.width / 2) {
			focus.x = (currentRoom.mainLayer.size.width * TILE_SIZE) - CANVAS_SIZE.width / 2;
		}
	}
	
	return mapCoordsMake(focus.x, focus.y);
}

- (void)drawGame {
	// camera target
	mapCoords focus = [self cameraTargetForFocus:cpv(player.position.x, round(player.position.y))];

	// draw layers. first get screen bounds in map coords
	int left = ((float)focus.x - CANVAS_SIZE.width / 2) / TILE_SIZE;
	int right = ((float)focus.x + CANVAS_SIZE.width / 2) / TILE_SIZE + 1;
	int top = ((float)focus.y + CANVAS_SIZE.height / 2) / TILE_SIZE + 1;
	int bottom = ((float)focus.y - CANVAS_SIZE.height / 2) / TILE_SIZE;

	// draw layers
	for (Layer *layer in currentRoom.layers) {
		if ([layer isKindOfClass:[ItemLayer class]]) continue;
		glPushMatrix();
		
		// parallax transformation
		float parallax = layer.parallax;
		if (parallax != 1.0) {
			cpVect parallaxFocus = cpv(focus.x * parallax, focus.y * parallax);
			int pLeft = (parallaxFocus.x - CANVAS_SIZE.width / 2) / TILE_SIZE - 1;
			int pRight = (parallaxFocus.x + CANVAS_SIZE.width / 2) / TILE_SIZE + 1;
			int pTop = (parallaxFocus.y + CANVAS_SIZE.height / 2) / TILE_SIZE + 1;
			int pBottom = (parallaxFocus.y - CANVAS_SIZE.height / 2) / TILE_SIZE - 1;
			glTranslatef(-(parallaxFocus.x - CANVAS_SIZE.width / 2), -(parallaxFocus.y - CANVAS_SIZE.height / 2), 0.0);
			
			glColor4f(1,1,1,1);
			[layer drawRect:mapRectMake(pLeft, pBottom, pRight-pLeft, pTop-pBottom) ignoreParallax:NO];
		}
		else {
			glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
			
			glColor4f(1,1,1,1);
			[layer drawRect:mapRectMake(left, bottom, right-left, top-bottom) ignoreParallax:NO];
			
			if(drawCollision && layer == currentRoom.mainLayer){
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				glDisable(GL_TEXTURE_2D);
				ChipmunkDebugDrawShapes(space);
				glEnable(GL_TEXTURE_2D);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				glColor3f(1,1,1);
			}
		}
		
		if (layer == currentRoom.mainLayer) {
			for (Item *item in items) {
				[item draw];
			}
			NSArray *allTextures = [Texture textures];
			for (Texture *texture in allTextures) {
				[texture draw];
			}
		}

		glPopMatrix();
	}
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
		[items addObject:item];
		if ([item respondsToSelector:@selector(addToSpace:)]) {
			[(PhysicsObject *)item addToSpace:space];
		}
		if ([item isKindOfClass:[Player class]]) {
			player = (Player *)item;
		}
	}
	
	[self setEditingLayer:currentRoom.mainLayer];	
}

-(void)updateStep {
	// update physics and let objects update
	for (Item *item in items) {
		[item update];
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
