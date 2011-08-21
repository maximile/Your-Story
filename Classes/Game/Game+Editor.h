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
