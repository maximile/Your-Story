//
//  Game+Editor.m
//  Your Story
//
//  Created by Max Williams on 28/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Game+Editor.h"


@implementation Game (Editor)

- (void)drawEditor {
	mapCoords focus = [self cameraTargetForFocus:editorFocus];
	editingLayer = currentRoom.mainLayer;
	glPushMatrix();
	glTranslatef(-(focus.x - CANVAS_SIZE.width / 2), -(focus.y - CANVAS_SIZE.height / 2), 0.0);
	[editingLayer drawRect:mapRectMake(0, 0, editingLayer.size.width, editingLayer.size.height)];
	glPopMatrix();	
}

- (mapCoords)mapCoordsForViewCoords:(pixelCoords)viewCoords {
	// get the point in layer space
	mapCoords focus = [self cameraTargetForFocus:editorFocus];
	pixelCoords translatedCoords = pixelCoordsMake(viewCoords.x + focus.x - CANVAS_SIZE.width / 2, viewCoords.y + focus.y - CANVAS_SIZE.height / 2);
	// and get the tile coords from that
	return mapCoordsMake(translatedCoords.x / TILE_SIZE, editingLayer.size.height - translatedCoords.y / TILE_SIZE - 1);
}

- (void)updateEditor {
	if (upKeyCount > 0) editorFocus = NSMakePoint(editorFocus.x, editorFocus.y + 1);
	if (downKeyCount > 0) editorFocus = NSMakePoint(editorFocus.x, editorFocus.y - 1);
	if (leftKeyCount > 0) editorFocus = NSMakePoint(editorFocus.x - 1, editorFocus.y);
	if (rightKeyCount > 0) editorFocus = NSMakePoint(editorFocus.x + 1, editorFocus.y);
	
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
	NSLog(@"%i, %i", coords.x, coords.y);
	[editingLayer setTile:mapCoordsMake(1,1) at:coords];
}


@end
