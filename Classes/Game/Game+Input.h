#import <Cocoa/Cocoa.h>
#import "Game.h"

@interface Game (Input)

- (void)upUp;
- (void)leftUp;
- (void)downUp;
- (void)rightUp;
- (void)upDown;
- (void)downDown;
- (void)leftDown;
- (void)rightDown;

- (void)tabDown;
- (void)tabUp;
- (void)spaceDown;
- (void)spaceUp;

- (void)numberDown:(int)number;

- (void)mouseDown:(pixelCoords)coords;
- (void)mouseDragged:(pixelCoords)coords;
- (void)mouseMoved:(pixelCoords)coords;

@end
