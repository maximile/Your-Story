//
//  Game+Editor.h
//  Your Story
//
//  Created by Max Williams on 28/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Game.h"

@interface Game (Editor)

- (void)drawEditor;
- (void)updateEditor;
- (void)changeTileAt:(mapCoords)coords;
- (mapCoords)mapCoordsForViewCoords:(pixelCoords)viewCoords;
- (void)setEditingLayer:(Layer *)newLayer;
- (void)selectTileFromPaletteAt:(pixelCoords)coords;

@end
