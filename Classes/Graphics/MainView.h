#import <Cocoa/Cocoa.h>

#import "FBO.h"
#import "Game+Input.h"

@interface GameView : NSOpenGLView {
	int scaleFactor;
	FBO *canvasFBO;
	
	Game *game;
	BOOL playing;
	NSTimer *animationTimer;
}

@property BOOL playing;
@property (assign) NSTimer *animationTimer;
@property (assign) Game *game;

- (void)play;

@end
