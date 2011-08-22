#import <Cocoa/Cocoa.h>
#import "Game.h"

@interface Game (Drawing)

- (pixelCoords)cameraTargetForFocus:(pixelCoords)focus;
- (void)drawGameOnCanvas:(FBO *)canvas;

@end
