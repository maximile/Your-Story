//
//  TileMap.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "TileMap.h"

NSString *InvalidImageError = @"InvalidImageError";

@implementation TileMap

@synthesize name;

- (TileMap *)initWithImage:(NSImage *)image {
	[super init];
	
	NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	if (bitmap == nil) {
		[NSException raise:InvalidImageError format:@"Invalid image"];
	}

	// check image dimensions
	NSSize bitmapSize = bitmap.size;
	width = bitmapSize.width;
	height = bitmapSize.height;
	if (width != height) {
		[NSException raise:InvalidImageError format:@"Image must be square"];
	}
	if (width < 16 || height < 16) {
		[NSException raise:InvalidImageError format:@"Image must be larger than 16x16"];
	}
	if (width > 2048 || height > 2048) {
		[NSException raise:InvalidImageError format:@"Image must be no bigger than 2048x2048"];
	}
	// check that it's a power of two
	int test = 16;
	while (test <= 2048) {
		if (width == test) {
			// it's a power of two
			break;
		}
		test *= 2;
	}
	if (test > 2048) {
		[NSException raise:InvalidImageError format:@"Image dimensions must be a power of 2"];
	}
		
	// prepare image data
	unsigned short *data = calloc(width*height, sizeof(unsigned short));
	for (int y=0; y<height; y++) {
		for (int x=0; x<width; x++) {
			NSColor *pixelColor = [bitmap colorAtX:x y:y];
			// get 5 bit int for every component
			unsigned short red = round([pixelColor redComponent] * 31);
			unsigned short green = round([pixelColor greenComponent] * 31);
			unsigned short blue = round([pixelColor blueComponent] * 31);
			unsigned short alpha = round([pixelColor alphaComponent] * 1);
			// RRRRRGGGGGBBBBBA
			data[y*width+x] = (red << 11) | (green << 6) | (blue << 1) | (alpha);
		}
	}

	// assign to OpenGL texture
	GLint saveName;
	glGenTextures(1, &name);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, name);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
	glBindTexture(GL_TEXTURE_2D, saveName);

	free(data);
	return self;
}

- (void)dealloc {
	glDeleteTextures(1, &name);
	[super dealloc];	
}

@end
