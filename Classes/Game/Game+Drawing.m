#import "Game+Drawing.h"
#import "ChipmunkDebugDraw.h"
#import "Player.h"
#import "Font.h"

@implementation Game (Drawing)

-(void)drawLightmap:(pixelCoords)focus over:(FBO *)canvas {
	[FBO bindFramebuffer:lightmapCanvas];
	
	GLfloat ambient = currentRoom.ambientLight;
	glClearColor(ambient, ambient, ambient, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glPushMatrix();
	glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE);
	
	for (Texture *texture in [Texture lightmapTextures]) {
		[texture draw];
	}

	glPopMatrix();
		
	
	// Now overlay it over the canvas
	[FBO bindFramebuffer:canvas];
	glBlendFunc(GL_DST_COLOR, GL_ZERO);
	
	[lightmapCanvas drawInRect:pixelRectMake(0, 0, CANVAS_SIZE.width, CANVAS_SIZE.height)];
	
	glDisable(GL_BLEND);
}

- (void)drawGameOnCanvas:(FBO *)canvas {
	[FBO bindFramebuffer:canvas];
	
	// camera target
	pixelCoords focus = [self cameraTargetForFocus:player.pixelPosition];

	// draw layers. first get screen bounds in map coords
	int left = ((float)focus.x - CANVAS_SIZE.width / 2) / TILE_SIZE;
	int right = ((float)focus.x + CANVAS_SIZE.width / 2) / TILE_SIZE + 1;
	int top = ((float)focus.y + CANVAS_SIZE.height / 2) / TILE_SIZE + 1;
	int bottom = ((float)focus.y - CANVAS_SIZE.height / 2) / TILE_SIZE;

	// draw layers
	for (Layer *layer in currentRoom.layers) {
		if ([layer isKindOfClass:[ItemLayer class]]) continue;
		glPushMatrix();
		
		glColor3f(1,1,1);
		
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
			
			if(drawCollision && layer == currentRoom.mainLayer){
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				glDisable(GL_TEXTURE_2D);
				ChipmunkDebugDrawShapes(space);
				glEnable(GL_TEXTURE_2D);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		}
		
		glColor3f(1,1,1);
		if (layer == currentRoom.mainLayer) {
			for (Item *item in items) {
				[item draw:self];
			}
			
			NSArray *allTextures = [Texture textures];
//			Texture *lightmapTexture = [Texture lightmapTexture];
			NSArray *lightmapTextures = [Texture lightmapTextures];
			for (Texture *texture in allTextures) {
				// sort of a hack...
				if ([lightmapTextures containsObject:texture]) continue;
				
				[texture draw];
			}
		}

		glPopMatrix();
	}
	
	[self drawLightmap:focus over:canvas];
	
		
	// draw UI
	for (Item *item in items) {
		[item drawInScreenCoords:self];
	}	
	[player drawStatus];
	for (Texture *texture in [Texture textures]) {
		[texture draw];
	}
}

- (pixelCoords)cameraTargetForFocus:(pixelCoords)focus {
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
	
	return pixelCoordsMake(focus.x, focus.y);
}

@end
