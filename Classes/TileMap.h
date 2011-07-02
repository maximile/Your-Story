//
//  TileMap.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

@interface TileMap : NSObject {
	GLuint name;
	int width;
	int height;
}

@property(readonly) GLuint name;

- (TileMap *)initWithImage:(NSImage *)image;

@end
