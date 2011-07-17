//
//  TileMap.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "TileMap.h"
#import <OpenGL/glu.h>
#import "Constants.h"
#import "Collision.h"

NSString *InvalidImageError = @"InvalidImageError";

@implementation TileMap

@synthesize name;

+ (tileCoords)tileCoordsFromString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@","];

	int x = [[components objectAtIndex:0] intValue];
	int y = [[components objectAtIndex:1] intValue];
	
	return tileCoordsMake(x, y);
}

- (TileMap *)initWithImage:(NSImage *)image {
	return [self initWithImage:image generateCollision:YES];
}

- (id)initWithImage:(NSImage *)image generateCollision:(BOOL)shouldGenerateCollision {
	if ([super init]==nil) return nil;
	
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
	if (width < TILE_SIZE || height < TILE_SIZE) {
		[NSException raise:InvalidImageError format:@"Image must be larger than %ix%i", TILE_SIZE, TILE_SIZE];
	}
	if (width > 2048 || height > 2048) {
		[NSException raise:InvalidImageError format:@"Image must be no bigger than 2048x2048"];
	}
	// check that it's a power of two
	int test = 1;
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
	
	if (shouldGenerateCollision) {
		collisionShapes = [[NSMutableArray arrayWithCapacity:width*height] retain];
		for (int y=0; y<height / TILE_SIZE; y++) {
			for (int x=0; x<width / TILE_SIZE; x++) {
				tileCoords coords = tileCoordsMake(x,y);
				mapSize dataSize = mapSizeMake(width, height);
				CollisionShape *shape = [Collision shapeForCoords:coords data:data dataSize:dataSize];
				[collisionShapes addObject:shape];
			}
		}
	}

	free(data);
	return self;
}

- (void)drawTile:(tileCoords)tile at:(tileCoords)loc {
	// get texture coordinates
	float tBottom = (tile.y * TILE_SIZE) / (float)height;
	float tTop = ((tile.y + 1) * TILE_SIZE) / (float)height;
	float tLeft = (tile.x * TILE_SIZE) / (float)width;
	float tRight = ((tile.x + 1) * TILE_SIZE) / (float)width;
	GLfloat texCoords[] = {tLeft, tTop, tRight, tTop, tRight, tBottom, tLeft, tBottom};
		
	// space coordinates
	float top = loc.y * TILE_SIZE; 
	float bottom = (loc.y + 1) * TILE_SIZE; 
	float left = loc.x * TILE_SIZE;
	float right = (loc.x + 1) * TILE_SIZE;
	GLfloat vertices[] = {left, top, right, top, right, bottom, left, bottom};
	
	glBindTexture(GL_TEXTURE_2D, name);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

- (CollisionShape *)shapeForTile:(tileCoords)coords {
	if (coords.x < 0 || coords.y < 0) return nil;
	int index = coords.y * (width/TILE_SIZE) + coords.x;
	return [collisionShapes objectAtIndex:index];
}

- (void)dealloc {
	glDeleteTextures(1, &name);
	[collisionShapes release];
	[super dealloc];	
}

@end
