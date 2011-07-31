#import <OpenGL/gl.h>

#import "GameView.h"
#import "Constants.h"
#import "Room.h"
#import "Types.h"

static NSOpenGLPixelFormatAttribute Attributes[] = {
	NSOpenGLPFANoRecovery,
	NSOpenGLPFAWindow,
	NSOpenGLPFAAccelerated,
	NSOpenGLPFADoubleBuffer,
	NSOpenGLPFAColorSize, 24,
	NSOpenGLPFAAlphaSize, 8,
	(NSOpenGLPixelFormatAttribute)nil	
};


@implementation GameView

@synthesize game;
@synthesize animationTimer;
@synthesize playing;

- (id)initWithFrame:(NSRect)frame {
	NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:Attributes];	
	[super initWithFrame:frame pixelFormat:pixelFormat];
	
	[pixelFormat release];
		
	return self;
}

- (void)updateGame {
	[game update];
	[self setNeedsDisplay:YES];
}

- (void)play {
	if (playing) return;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateGame) userInfo:nil repeats:YES];
}

- (void)pause {
	if (!playing) return;
	self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer {
	[animationTimer invalidate];
	animationTimer = newTimer;
}

- (void)drawRect:(NSRect)rect {
	// clear the scren
	glClearColor(0.75, 0.75, 0.75, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// draw game to main FBO
	[FBO bindFramebuffer:canvasFBO];
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glColor3f(1.0, 1.0, 1.0);
	[game draw];
	[FBO bindFramebuffer:nil];
	
	// get centred rect to draw FBO to
	int stretchedCanvasWidth = CANVAS_SIZE.width * scaleFactor;
	int stretchedCanvasHeight = CANVAS_SIZE.height * scaleFactor;
	int leftEdge = self.frame.size.width / 2 - stretchedCanvasWidth / 2;
	int topEdge = self.frame.size.height / 2 - stretchedCanvasHeight / 2;
	pixelRect centreRect = pixelRectMake(leftEdge, topEdge, stretchedCanvasWidth, stretchedCanvasHeight);
	
	// draw FBO contents
	[canvasFBO drawInRect:centreRect];
	
	[[self openGLContext] flushBuffer];
}

- (void)prepareOpenGL {
	glDisable(GL_DITHER);
	glDisable(GL_STENCIL_TEST);
	glDisable(GL_FOG);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_BLEND);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.5f);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// create an FBO which will be scaled up to draw in the screen
	// (why do I need that cast there?)
	canvasFBO = [(FBO *)[FBO alloc] initWithSize:CANVAS_SIZE];
	
	GLint swapInterval = 1;
	[[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	[self reshape];
}

- (void)reshape {
	NSRect visibleRect = [self visibleRect];
	float windowWidth = NSWidth(visibleRect);
	float windowHeight = NSHeight(visibleRect);

	glLoadIdentity();
	glViewport(0, 0, windowWidth, windowHeight);
	glOrtho(0, windowWidth, 0, windowHeight, -1.0, 1.0);
	
	// set the scaleFactor so that the canvas will be scaled to the largest rect that will fit in the window while keeping all pixels square
	scaleFactor = 1;
	while ((CANVAS_SIZE.width*(scaleFactor+1) <= windowWidth) && (CANVAS_SIZE.height*(scaleFactor+1) <= windowHeight)) {
		scaleFactor++;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)awakeFromNib {
	// set minimum size and make sure it's not already smaller
	NSWindow *window = self.window;
	NSSize minContentSize = NSMakeSize(CANVAS_SIZE.width * 2, CANVAS_SIZE.height * 2);
	[window setContentMinSize:minContentSize];
	if (self.frame.size.width < minContentSize.width) {
		[window setContentSize:NSMakeSize(minContentSize.width, self.frame.size.height)];
	}
	if (self.frame.size.height < minContentSize.height) {
		[window setContentSize:NSMakeSize(self.frame.size.width, minContentSize.height)];
	}
}

- (void)keyUp:(NSEvent *)event {
	switch (event.keyCode) {
		case 126: [game upUp]; break; // upArrow
		case 13: [game upUp]; break; // w
		case 125: [game downUp]; break; // downArrow
		case 1: [game downUp]; break; // s
		case 124: [game rightUp]; break; // rightArrow
		case 2: [game rightUp]; break; // d
		case 123: [game leftUp]; break; // leftArrow
		case 0: [game leftUp]; break; // a
		case 48: [game tabUp]; break; // tab
		default: break;
	}
}

- (void)keyDown:(NSEvent *)event {
	switch (event.keyCode) {
		case 126: [game upDown]; break; // upArrow
		case 13: [game upDown]; break; // w
		case 125: [game downDown]; break; // downArrow
		case 1: [game downDown]; break; // s
		case 124: [game rightDown]; break; // rightArrow
		case 2: [game rightDown]; break; // d
		case 123: [game leftDown]; break; // leftArrow
		case 0: [game leftDown]; break; // a
		case 48: [game tabDown]; break; // tab
		default: break;
	}
	// test for number input
	for (int i = 0; i <= 9; i++) {
		if ([event.characters isEqualToString:[NSString stringWithFormat:@"%i", i]]) {
			[game numberDown:i];
		}
	}
}

- (void)mouseDown:(NSEvent *)event {
	NSPoint viewCoords = [self convertPoint:event.locationInWindow fromView:nil];
	
	// compensate for offset
	int stretchedCanvasWidth = CANVAS_SIZE.width * scaleFactor;
	int stretchedCanvasHeight = CANVAS_SIZE.height * scaleFactor;
	int leftEdge = self.frame.size.width / 2 - stretchedCanvasWidth / 2;
	int topEdge = self.frame.size.height / 2 - stretchedCanvasHeight / 2;
	viewCoords = NSMakePoint(viewCoords.x - leftEdge, viewCoords.y - topEdge);
	
	pixelCoords scaledCoords = pixelCoordsMake(viewCoords.x / scaleFactor, viewCoords.y / scaleFactor);
	[game mouseDown:scaledCoords];
}

- (void)mouseDragged:(NSEvent *)event {
	NSPoint viewCoords = [self convertPoint:event.locationInWindow fromView:nil];
	
	// compensate for offset
	int stretchedCanvasWidth = CANVAS_SIZE.width * scaleFactor;
	int stretchedCanvasHeight = CANVAS_SIZE.height * scaleFactor;
	int leftEdge = self.frame.size.width / 2 - stretchedCanvasWidth / 2;
	int topEdge = self.frame.size.height / 2 - stretchedCanvasHeight / 2;
	viewCoords = NSMakePoint(viewCoords.x - leftEdge, viewCoords.y - topEdge);
	
	pixelCoords scaledCoords = pixelCoordsMake(viewCoords.x / scaleFactor, viewCoords.y / scaleFactor);
	[game mouseDragged:scaledCoords];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

@end
