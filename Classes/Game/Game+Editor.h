#import <Cocoa/Cocoa.h>
#import "Game.h"

@interface Game (Editor)

- (void)drawEditorOnCanvas:(FBO *)canvas;
- (void)updateEditor;
- (void)changeTileAt:(mapCoords)coords;
- (void)deleteTileAt:(mapCoords)coords;
- (mapCoords)mapCoordsForViewCoords:(pixelCoords)viewCoords;
- (void)setEditingLayer:(Layer *)newLayer;
- (void)selectTileFromPaletteAt:(pixelCoords)coords;

@end
