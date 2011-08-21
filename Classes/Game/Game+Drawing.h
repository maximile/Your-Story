#import <Cocoa/Cocoa.h>
#import "Game.h"

@interface Game (Drawing)

- (mapCoords)cameraTargetForFocus:(cpVect)focus;
- (void)drawGame;

@end
