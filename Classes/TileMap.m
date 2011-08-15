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

NSString *InvalidImageErrorABOUTTOGO = @"InvalidImageError";

@implementation TileMap

@synthesize textureName, name, size;

static NSMutableDictionary *mapCache = nil;
+ (TileMap *)mapNamed:(NSString *)mapName {
	// initialise cache if necessary
	if (mapCache == nil) {
		mapCache = [NSMutableDictionary dictionaryWithCapacity:0];
	}
	
	// check if the cache contains a map with the given name
	TileMap *map = [mapCache valueForKey:mapName];
	if (map == nil) {
		// not cached; load it as usual
		NSImage *mapImage = [NSImage imageNamed:mapName];
		
		map = [[TileMap alloc] initWithImage:mapImage];		
		[mapCache setValue:map forKey:mapName];
	}
	
	map.name = mapName;
	return map;
}

+ (void)emptyCache {
	[mapCache removeAllObjects];
}

+ (mapCoords)mapCoordsFromString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@","];

	int x = [[components objectAtIndex:0] intValue];
	int y = [[components objectAtIndex:1] intValue];
	
	return mapCoordsMake(x, y);
}

- (TileMap *)initWithImage:(NSImage *)image {
	return [self initWithImage:image generateCollision:YES];
}

- (id)initWithImage:(NSImage *)image generateCollision:(BOOL)shouldGenerateCollision {
	if ([super init]==nil) return nil;
	
	NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	if (bitmap == nil) {
		[NSException raise:InvalidImageErrorABOUTTOGO format:@"Invalid image"];
	}

	// check image dimensions
	imageSize = pixelSizeMake(bitmap.size.width, bitmap.size.height);
	if (imageSize.width != imageSize.height) {
		[NSException raise:InvalidImageErrorABOUTTOGO format:@"Image must be square"];
	}
	if (imageSize.width < TILE_SIZE || imageSize.height < TILE_SIZE) {
		[NSException raise:InvalidImageErrorABOUTTOGO format:@"Image must be larger than %ix%i", TILE_SIZE, TILE_SIZE];
	}
	if (imageSize.width > 2048 || imageSize.height > 2048) {
		[NSException raise:InvalidImageErrorABOUTTOGO format:@"Image must be no bigger than 2048x2048"];
	}
	// check that it's a power of two
	int test = 1;
	while (test <= 2048) {
		if (imageSize.width == test) {
			// it's a power of two
			break;
		}
		test *= 2;
	}
	if (test > 2048) {
		[NSException raise:InvalidImageErrorABOUTTOGO format:@"Image dimensions must be a power of 2"];
	}
		
	// prepare image data
	unsigned short *data = calloc(imageSize.width * imageSize.height, sizeof(unsigned short));
	for (int y=0; y<imageSize.height; y++) {
		for (int x=0; x<imageSize.width; x++) {
			NSColor *pixelColor = [bitmap colorAtX:x y:y];
			// get 5 bit int for every component
			unsigned short red = round([pixelColor redComponent] * 31);
			unsigned short green = round([pixelColor greenComponent] * 31);
			unsigned short blue = round([pixelColor blueComponent] * 31);
			unsigned short alpha = round([pixelColor alphaComponent] * 1);
			// RRRRRGGGGGBBBBBA
			data[y*imageSize.width+x] = (red << 11) | (green << 6) | (blue << 1) | (alpha);
		}
	}

	// assign to OpenGL texture
	GLint saveName;
	glGenTextures(1, &textureName);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageSize.width, imageSize.height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
	glBindTexture(GL_TEXTURE_2D, saveName);
	
	// how many tiles fit on the map
	size = mapSizeMake(imageSize.width / TILE_SIZE, imageSize.height / TILE_SIZE);
	
	// generate collision shapes if necessary
	if (shouldGenerateCollision) {
		int tileCount = size.width * size.height;
		collisionShapes = [NSMutableArray arrayWithCapacity:tileCount];
		for (int y = 0; y < size.height; y++) {
			for (int x = 0; x < size.width; x++) {
				mapCoords coords = mapCoordsMake(x, y);
				pixelSize dataSize = pixelSizeMake(imageSize.width, imageSize.height);
				CollisionShape *shape = [Collision shapeForCoords:coords data:data dataSize:dataSize];
				[collisionShapes addObject:shape];
			}
		}
	}

	free(data);
	return self;
}

- (void)drawTile:(mapCoords)tile at:(mapCoords)loc {
	// could do a million things to speed this up if necessary
	
	// get texture coordinates
	float tBottom = (tile.y * TILE_SIZE) / (float)imageSize.height;
	float tTop = ((tile.y + 1) * TILE_SIZE) / (float)imageSize.height;
	float tLeft = (tile.x * TILE_SIZE) / (float)imageSize.width;
	float tRight = ((tile.x + 1) * TILE_SIZE) / (float)imageSize.width;
	GLfloat texCoords[] = {tLeft, tTop, tRight, tTop, tRight, tBottom, tLeft, tBottom};
		
	// space coordinates
	float top = loc.y * TILE_SIZE; 
	float bottom = (loc.y + 1) * TILE_SIZE; 
	float left = loc.x * TILE_SIZE;
	float right = (loc.x + 1) * TILE_SIZE;
	GLfloat vertices[] = {left, top, right, top, right, bottom, left, bottom};
	
	glBindTexture(GL_TEXTURE_2D, textureName);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (CollisionShape *)shapeForTile:(mapCoords)coords {
	if (coords.x < 0 || coords.y < 0) return nil;
	int index = coords.y * (size.width) + coords.x;
	return [collisionShapes objectAtIndex:index];
}

- (void)finalize {
	glDeleteTextures(1, &textureName);
	[super finalize];	
}

@end
