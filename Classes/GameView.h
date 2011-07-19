#import <Cocoa/Cocoa.h>

#import "FBO.h"
#import "Game.h"

@interface GameView : NSOpenGLView {
	int scaleFactor;
	FBO *canvasFBO;
	
	Game *game;
	BOOL playing;
	NSTimer *animationTimer;
}

@property BOOL playing;
@property (nonatomic, assign) NSTimer *animationTimer;
@property (retain) Game *game;

- (void)play;

@end
