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
- (void)zDown;
- (void)zUp;
- (void)xDown;
- (void)xUp;

- (void)numberDown:(int)number;

- (void)shiftDown:(BOOL)upDown;

- (void)mouseDown:(pixelCoords)coords;
- (void)mouseDragged:(pixelCoords)coords;
- (void)rightMouseDown:(pixelCoords)coords;
- (void)rightMouseDragged:(pixelCoords)coords;
- (void)mouseMoved:(pixelCoords)coords;

@end
