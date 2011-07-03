//
//  GameView.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "GameView.h"
#import <OpenGL/gl.h>

#import "Room.h"

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

Room *room = nil;

- (id)initWithFrame:(NSRect)frame {
	NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:Attributes];	
	[super initWithFrame:frame pixelFormat:pixelFormat];
	
	[pixelFormat release];
	canvasSize = NSMakeSize(320,180);
	
	return self;
}



- (void)drawRect:(NSRect)rect {
	glClearColor(0.75, 0.75, 0.75, 1.0);	
	glClear(GL_COLOR_BUFFER_BIT);
	glColor3f(1.0, 1.0, 1.0);
	
	if (room == nil) {
		room = [[Room alloc] initWithName:@"Test"];
	}
	[room draw];
	
	[[self openGLContext] flushBuffer];
}

- (void)prepareOpenGL {
	glDisable(GL_DITHER);
	glDisable(GL_STENCIL_TEST);
	glDisable(GL_FOG);
	glDisable(GL_DEPTH_TEST);

	glDisable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glAlphaFunc(GL_GREATER,0.5f);
	glEnable(GL_ALPHA_TEST);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	GLint swapInterval = 1;
	[[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	[self reshape];
}

- (void)reshape {
	NSRect visibleRect = [self visibleRect];
	float windowWidth = NSWidth(visibleRect);
	float windowHeight = NSHeight(visibleRect);
	float canvasWidth = canvasSize.width;
	float canvasHeight = canvasSize.height;

	glLoadIdentity();
	glViewport(0, 0, windowWidth, windowHeight);
	glOrtho(0, windowWidth, 0, windowHeight, -1.0, 1.0);
	
	scaleFactor = 1;
	while ((canvasWidth*(scaleFactor+1) <= windowWidth) && (canvasHeight*(scaleFactor+1) <= windowHeight)) {
		scaleFactor++;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)awakeFromNib {
	// set minimum size and make sure it's not already smaller
	NSWindow *window = self.window;
	NSSize minContentSize = NSMakeSize(canvasSize.width * 2, canvasSize.height * 2);
	[window setContentMinSize:minContentSize];
	if (self.frame.size.width < minContentSize.width) {
		[window setContentSize:NSMakeSize(minContentSize.width, self.frame.size.height)];
	}
	if (self.frame.size.height < minContentSize.height) {
		[window setContentSize:NSMakeSize(self.frame.size.width, minContentSize.height)];
	}
}


@end
