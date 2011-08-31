#import "Game+Input.h"
#import "Game+Editor.h"

@implementation Game (Input)

// ==================
// = Keyboard Input =
// ==================

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

- (void)zDown {zKey=YES;}
- (void)zUp {zKey=NO;}
- (void)xDown {xKey=YES;}
- (void)xUp {xKey=NO;}

- (void)shiftDown:(BOOL)upDown {
	shiftKey = upDown;
}

- (void)numberDown:(int)number {
	if (mode == EDITOR_MODE) {
		int newLayerIndex = number - 1;
		int layerCount = currentRoom.layers.count;
		if (newLayerIndex >= layerCount) {
			NSBeep();
			return;
		}
		if (number == 0) {
			[self setEditingLayer:currentRoom.itemLayer];
		}
		else {
			[self setEditingLayer:[currentRoom.layers objectAtIndex:number - 1]];
		}
	}
}

// ===============
// = Mouse Input =
// ===============

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


@end
