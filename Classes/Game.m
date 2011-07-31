#import "Game.h"
#import "GameObject.h"
#import "Constants.h"
#import "Game+Editor.h"

@implementation Game

@synthesize mode, currentRoom;

- (id)init {
	if ([super init] == nil) {
		return nil;
	}
	items = [[NSMutableArray alloc] initWithCapacity:0];
	player = [[Player alloc] init];
	[items addObject:player];
	player.position = NSMakePoint(50, 50);
	
	upKeyCount = 0;
	downKeyCount = 0;
	leftKeyCount = 0;
	rightKeyCount = 0;
	
	currentRoom = [[Room alloc] initWithName:@"Test"];
	
	mode = EDITOR_MODE;
	
	return self;
}

- (mapCoords)cameraTargetForFocus:(NSPoint)focus {
	if (currentRoom.mainLayer.size.height * TILE_SIZE <= CANVAS_SIZE.height) {
		// room is shorter than the screen, center it vertically
		focus.y = CANVAS_SIZE.height / 2;
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
		focus.x = CANVAS_SIZE.width / 2;
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
			NSPoint parallaxFocus = NSMakePoint(focus.x * parallax, focus.y * parallax);
			int pLeft = (parallaxFocus.x - CANVAS_SIZE.width / 2) / TILE_SIZE - 1;
			int pRight = (parallaxFocus.x + CANVAS_SIZE.width / 2) / TILE_SIZE + 1;
			int pTop = (parallaxFocus.y + CANVAS_SIZE.height / 2) / TILE_SIZE + 1;
			int pBottom = (parallaxFocus.y - CANVAS_SIZE.height / 2) / TILE_SIZE - 1;
			glTranslatef(-(parallaxFocus.x - CANVAS_SIZE.width / 2), -(parallaxFocus.y - CANVAS_SIZE.height / 2), 0.0);
			[layer drawRect:mapRectMake(pLeft, pBottom, pRight-pLeft, pTop-pBottom)];		
		}
		else {
			glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
	        [layer drawRect:mapRectMake(left, bottom, right-left, top-bottom)];
		}

		glPopMatrix();
	}
	glPushMatrix();
	glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
	for (GameObject *item in items) {
		[item draw];
	}
	glPopMatrix();
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

- (void)update {
	switch (mode) {
		case GAME_MODE:
			if (upKeyCount > 0) player.position = NSMakePoint(player.position.x, player.position.y + 1);
			if (downKeyCount > 0) player.position = NSMakePoint(player.position.x, player.position.y - 1);
			if (leftKeyCount > 0) player.position = NSMakePoint(player.position.x - 1, player.position.y);
			if (rightKeyCount > 0) player.position = NSMakePoint(player.position.x + 1, player.position.y);
			for (GameObject *item in items) {
				[item update];
			}
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
			[self changeTileAt:[self mapCoordsForViewCoords:coords]];
			break;
		default:
			break;
	}
}

- (void)upDown {upKeyCount=1;}
- (void)downDown {downKeyCount=1;}
- (void)leftDown {leftKeyCount=1;}
- (void)rightDown {rightKeyCount=1;}
- (void)upUp {upKeyCount=0;}
- (void)downUp {downKeyCount=0;}
- (void)leftUp {leftKeyCount=0;}
- (void)rightUp {rightKeyCount=0;}

@end
