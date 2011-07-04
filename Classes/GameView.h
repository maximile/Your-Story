//
//  GameView.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FBO.h"

@interface GameView : NSOpenGLView {
	NSSize canvasSize;
	int scaleFactor;
	FBO *canvasFBO;
}

@end
