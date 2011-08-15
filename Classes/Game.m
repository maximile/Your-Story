#import "Game.h"
#import "GameObject.h"
#import "Constants.h"
#import "Game+Editor.h"

@implementation Game

@synthesize mode, currentRoom, editingLayer, cursorLoc;

- (id)init {
	if ([super init] == nil) {
		return nil;
	}
	items = [[NSMutableArray alloc] initWithCapacity:0];
	player = [[Player alloc] init];
	[items addObject:player];
	
	space = cpSpaceNew();
	cpSpaceSetGravity(space, cpv(0, -100));
	
	[self setCurrentRoom:[[Room alloc] initWithName:@"Another"]];
	[player addToSpace:space];
	player.position = cpv(235, 232);
	
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
	mapCoords focus = [self cameraTargetForFocus:player.position];

	// draw layers. first get screen bounds in map coords
	int left = ((float)focus.x - CANVAS_SIZE.width / 2) / TILE_SIZE;
	int right = ((float)focus.x + CANVAS_SIZE.width / 2) / TILE_SIZE + 1;
	int top = ((float)focus.y + CANVAS_SIZE.height / 2) / TILE_SIZE + 1;
	int bottom = ((float)focus.y - CANVAS_SIZE.height / 2) / TILE_SIZE;

	// draw layers
	for (Layer *layer in currentRoom.layers) {
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
			[layer drawRect:mapRectMake(pLeft, pBottom, pRight-pLeft, pTop-pBottom) ignoreParallax:NO];
		}
		else {
			glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
	        [layer drawRect:mapRectMake(left, bottom, right-left, top-bottom) ignoreParallax:NO];
			if (drawCollision && layer == currentRoom.mainLayer) [layer drawCollision];
		}
		
		if (layer == currentRoom.mainLayer) {
			for (GameObject *item in items) {
				[item draw];
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
	[currentRoom.mainLayer addToSpace:space];
	[self setEditingLayer:currentRoom.mainLayer];
}

- (void)updateGame {
	directionMask directionInput = NOWHERE;
	// get keyboard input
	if (upKey) { directionInput |= UP; }
	if (downKey) { directionInput |= DOWN; }
	if (leftKey) { directionInput |= LEFT; }
	if (rightKey) { directionInput |= RIGHT; }
	[player setInput:directionInput];
	
	drawCollision = tabKey;
		
	// update physics and let objects update
	for (GameObject *item in items) {
		[item update];
	}
	cpSpaceStep(space, 1.0/60.0);
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


- (void)mouseDown:(pixelCoords)coords {
	switch (mode) {
		case EDITOR_MODE:
			if (showPalette)
				[self selectTileFromPaletteAt:coords];
			else {
				[self changeTileAt:[self mapCoordsForViewCoords:coords]];
			}
			break;
		default:
			break;
	}
}

- (void)mouseDragged:(pixelCoords)coords {
	if (mode == EDITOR_MODE) {
		if (showPalette)
			[self selectTileFromPaletteAt:coords];
		else {
			[self changeTileAt:[self mapCoordsForViewCoords:coords]];
		}
	}
}

- (void)mouseMoved:(pixelCoords)coords {
	if (mode == EDITOR_MODE) {
		if (!showPalette) {
			self.cursorLoc = [self mapCoordsForViewCoords:coords];
		}
	}
}

- (void)upDown {upKey=YES;}
- (void)downDown {downKey=YES;}
- (void)leftDown {leftKey=YES;}
- (void)rightDown {rightKey=YES;}
- (void)upUp {upKey=NO;}
- (void)downUp {downKey=NO;}
- (void)leftUp {leftKey=NO;}
- (void)rightUp {rightKey=NO;}

- (void)tabDown {tabKey=YES;}
- (void)tabUp {tabKey=NO;}

- (void)numberDown:(int)number {
	if (mode == EDITOR_MODE) {
		if (number - 1 >= currentRoom.layers.count) {
			NSBeep();
			return;
		}
		[self setEditingLayer:[currentRoom.layers objectAtIndex:number - 1]];
	}
}

- (void)setCurrentRoomFromPath:(NSString *)path {
	self.currentRoom = [[Room alloc] initWithFile:path];
}

- (void)writeCurrentRoomToPath:(NSString *)path {
	[self.currentRoom writeToFile:path];
}


@end
