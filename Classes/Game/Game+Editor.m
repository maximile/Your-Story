#import "Game+Editor.h"
#import "Game+Drawing.h"

@implementation Game (Editor)

- (void)drawEditorOnCanvas:(FBO *)canvas {
	[FBO bindFramebuffer:canvas];
	
	pixelCoords focus = [self cameraTargetForFocus:editorFocus];
	if (drawOtherLayers) {
		NSMutableArray *layersToDraw = [NSMutableArray arrayWithArray:currentRoom.layers];
		[layersToDraw addObject:currentRoom.itemLayer];
		for (Layer *layer in layersToDraw) {
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
		        [layer drawRect:mapRectMake(0, 0, layer.size.width, layer.size.height) ignoreParallax:NO];
			}

			glPopMatrix();
		}
	}
	else {
		glPushMatrix();
		glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
		[editingLayer drawRect:mapRectMake(0, 0, editingLayer.size.width, editingLayer.size.height) ignoreParallax:YES];
		[uiMap drawTile:mapCoordsMake(0,0) at:mapCoordsMake(cursorLoc.x, editingLayer.size.height - cursorLoc.y - 1)];
		glPopMatrix();
	}
	
	if (showPalette) {
		glPushMatrix();
		// offset to centre in screen
		int xOffset = CANVAS_SIZE.width / 2 - palette.size.width * TILE_SIZE / 2;
		int yOffset = CANVAS_SIZE.height / 2 - palette.size.height * TILE_SIZE / 2;
		glTranslatef(xOffset, yOffset, 0.0);

		// palette coords
		int bottom = 0;
		int top = palette.size.height * TILE_SIZE;
		int left = 0;
		int right = palette.size.width * TILE_SIZE;
		
		// draw black background
		glColor3f(0.0, 0.0, 0.0);
		glBegin(GL_QUADS);
		glVertex2f(left - 3, bottom - 4);
		glVertex2f(right + 4, bottom - 4);
		glVertex2f(right + 4, top + 3);
		glVertex2f(left - 3, top + 3);
		glEnd();
		
		// draw outline
		glColor3f(1.0, 1.0, 0.0);
		glBegin(GL_LINE_LOOP);
		glVertex2f(left - 2, bottom - 2);
		glVertex2f(right + 2, bottom - 2);
		glVertex2f(right + 2, top + 2);
		glVertex2f(left - 2, top + 2);
		glEnd();
		
		// draw palette
		glColor3f(1.0, 1.0, 1.0);
		[palette drawRect:mapRectMake(0, 0, palette.size.width, palette.size.height) ignoreParallax:YES];
		
		// highlight selected palette tile
		glBegin(GL_LINE_LOOP);
		pixelCoords selectedOffset = pixelCoordsMake(paletteTile.x * TILE_SIZE, (palette.size.height - paletteTile.y - 1) * TILE_SIZE);
		glVertex2f(selectedOffset.x - 1, selectedOffset.y);
		glVertex2f(selectedOffset.x + TILE_SIZE, selectedOffset.y);
		glVertex2f(selectedOffset.x + TILE_SIZE, selectedOffset.y + TILE_SIZE + 1);
		glVertex2f(selectedOffset.x - 1, selectedOffset.y + TILE_SIZE + 1);
		glEnd();
		
		glPopMatrix();
	}
	
}

- (void)selectTileFromPaletteAt:(pixelCoords)coords {
	int xOffset = CANVAS_SIZE.width / 2 - palette.size.width * TILE_SIZE / 2;
	int yOffset = CANVAS_SIZE.height / 2 - palette.size.height * TILE_SIZE / 2;
	coords.x -= xOffset;
	coords.y -= yOffset;
	
	paletteTile = mapCoordsMake(coords.x / TILE_SIZE, palette.size.height - coords.y / TILE_SIZE - 1);
}

- (void)setEditingLayer:(Layer *)newLayer {
	if (newLayer == editingLayer) {
		drawOtherLayers = !drawOtherLayers;
		return;
	}
	editingLayer = newLayer;
	drawOtherLayers = NO;
	// generate palette layer from new layer's tilemap
	palette = [editingLayer makePaletteLayer];
	NSLog(@"setting palette: %@", palette);
}

- (mapCoords)mapCoordsForViewCoords:(pixelCoords)viewCoords {
	// get the point in layer space
	pixelCoords focus = [self cameraTargetForFocus:editorFocus];
	pixelCoords translatedCoords = pixelCoordsMake(viewCoords.x + focus.x - CANVAS_SIZE.width / 2, viewCoords.y + focus.y - CANVAS_SIZE.height / 2);
	// and get the tile coords from that
	return mapCoordsMake(translatedCoords.x / TILE_SIZE, editingLayer.size.height - translatedCoords.y / TILE_SIZE - 1);
}

- (void)updateEditor {
	int scrollSpeed = 1;
	if (shiftKey) scrollSpeed *= 3;
	
	if (upKey) editorFocus = pixelCoordsMake(editorFocus.x, editorFocus.y + scrollSpeed);
	if (downKey) editorFocus = pixelCoordsMake(editorFocus.x, editorFocus.y - scrollSpeed);
	if (leftKey) editorFocus = pixelCoordsMake(editorFocus.x - scrollSpeed, editorFocus.y);
	if (rightKey) editorFocus = pixelCoordsMake(editorFocus.x + scrollSpeed, editorFocus.y);
	
	showPalette = tabKey;
	
	if (CANVAS_SIZE.width > editingLayer.size.width * TILE_SIZE) {
		editorFocus.x = editingLayer.size.width * TILE_SIZE / 2;
	}
	else if (editorFocus.x < CANVAS_SIZE.width / 2) {
		editorFocus.x = CANVAS_SIZE.width / 2;
	}
	else if (editorFocus.x > editingLayer.size.width * TILE_SIZE - CANVAS_SIZE.width / 2) {
		editorFocus.x = editingLayer.size.width * TILE_SIZE - CANVAS_SIZE.width / 2;
	}
	
	if (CANVAS_SIZE.height > editingLayer.size.height * TILE_SIZE) {
		editorFocus.y = editingLayer.size.height * TILE_SIZE / 2;
	}
	else if (editorFocus.y < CANVAS_SIZE.height / 2) {
		editorFocus.y = CANVAS_SIZE.height / 2;
	}
	else if (editorFocus.y > editingLayer.size.height * TILE_SIZE - CANVAS_SIZE.height / 2) {
		editorFocus.y = editingLayer.size.height * TILE_SIZE - CANVAS_SIZE.height / 2;
	}
}

- (void)changeTileAt:(mapCoords)coords {
	[editingLayer setTile:paletteTile at:coords];
}


@end
