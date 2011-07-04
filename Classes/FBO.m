//
//  FBO.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "FBO.h"


@implementation FBO

@synthesize width, height, textureWidth, textureHeight, name;

+ (void)bindFramebuffer:(FBO *)buffer {
	GLuint bufferName = 0;
	if (buffer) {
		bufferName = buffer.name;
	}
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, bufferName);
}

- (id)initWithWidth:(int)newWidth height:(int)newHeight {
	if ([super init] == nil) return nil;
	
	width = newWidth;
	height = newHeight;
	
	// get enclosing power of two dimensions
	textureWidth = 2;
	while (textureWidth<width) textureWidth *= 2;
	textureHeight = 2;
	while (textureHeight<height) textureHeight *= 2;
	
	glGenTextures(1, &textureName);
	glBindTexture(GL_TEXTURE_2D, textureName);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);	
	
	glGenFramebuffersEXT(1, &name);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, name);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, textureName, 0);
	
	glBindTexture(GL_TEXTURE_2D,0);
	
	GLenum status;
	status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if (status != GL_FRAMEBUFFER_COMPLETE_EXT) {
		NSLog(@"Something terrible happened.");
	}
			
	return self;
}

- (void)bind {
	glBindTexture(GL_TEXTURE_2D, textureName);
}

- (void)drawInRect:(NSRect)rect {
	[self bind];
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	GLfloat	coordinates[] = {
		0, 0,
		(float)width/(float)textureWidth, 0,
		0, (float)height/(float)textureHeight,
		(float)width/(float)textureWidth, (float)height/(float)textureHeight,
	};
	GLfloat vertices[] = {
		rect.origin.x, rect.origin.y,
		rect.origin.x + rect.size.width, rect.origin.y,
		rect.origin.x, rect.origin.y + rect.size.height,
		rect.origin.x + rect.size.width, rect.origin.y + rect.size.height,
	};
		
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc {
	glDeleteFramebuffersEXT(1, &name);
	glDeleteTextures(1,&textureName);
	[super dealloc];
}

@end
