//
//  GameView.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FBO.h"
#import "Game.h"

@interface GameView : NSOpenGLView {
	NSSize canvasSize;
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
