#import "Game+Drawing.h"
#import "ChipmunkDebugDraw.h"
#import "Player.h"

@implementation Game (Drawing)

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

@end
