#import "PaletteView.h"
#import <OpenGL/gl.h>

static NSOpenGLPixelFormatAttribute Attributes[] = {
	NSOpenGLPFANoRecovery,
	NSOpenGLPFAWindow,
	NSOpenGLPFAAccelerated,
	NSOpenGLPFADoubleBuffer,
	NSOpenGLPFAColorSize, 24,
	NSOpenGLPFAAlphaSize, 8,
	(NSOpenGLPixelFormatAttribute)nil	
};

@implementation PaletteView

@synthesize layer;

- (id)initWithFrame:(NSRect)frame {
	NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:Attributes];	
	[super initWithFrame:frame pixelFormat:pixelFormat];
	
	[pixelFormat release];
		
	return self;
}

- (void)drawRect:(NSRect)rect {
	// clear the scren
	glClearColor(0.75, 0.75, 0.75, 1.0);	
	glClear(GL_COLOR_BUFFER_BIT);
	
	if (canvasFBO == nil) {
		[[self openGLContext] flushBuffer];
		return;
	}
	
	// draw layer to main FBO
	[FBO bindFramebuffer:canvasFBO];
	glColor3f(1.0, 1.0, 1.0);
	[layer drawRect:mapRectMake(0, 0, layer.size.width, layer.size.height)];
	[FBO bindFramebuffer:nil];
		
	// draw FBO contents
	NSRect visibleRect = [self visibleRect];
	float width = NSWidth(visibleRect);
	float height = NSHeight(visibleRect);
	[canvasFBO drawInRect:pixelRectMake(0, 0, width, height)];

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
	
	GLint swapInterval = 1;
	[[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	[self reshape];
}

- (void)setLayer:(Layer *)newLayer {
	[self lockFocus];
	if (layer == newLayer) return;
	layer = newLayer;
	canvasFBO = [(FBO *)[FBO alloc] initWithSize:pixelSizeMake(layer.size.width * TILE_SIZE, layer.size.height * TILE_SIZE)];
}

- (void)reshape {
	NSRect visibleRect = [self visibleRect];
	float width = NSWidth(visibleRect);
	float height = NSHeight(visibleRect);

	glLoadIdentity();
	glViewport(0, 0, width, height);
	glOrtho(0, width, 0, height, -1.0, 1.0);

	[self setNeedsDisplay:YES];
}


@end
