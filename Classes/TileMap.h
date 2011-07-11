//
//  TileMap.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

typedef struct {
	int x;
	int y;
} tileCoords;

typedef struct {
	int width;
	int height;
} mapSize;

static inline mapSize mapSizeMake(int width, int height) {
	return (mapSize){width, height};
}
static inline tileCoords tileCoordsMake(int x, int y) {
	return (tileCoords){x, y};
}

#define NO_TILE (tileCoords){-1,-1}


@interface TileMap : NSObject {
	GLuint name;
	int width;
	int height;
}

@property(readonly) GLuint name;

- (TileMap *)initWithImage:(NSImage *)image;
- (void)drawTile:(tileCoords)tile at:(tileCoords)loc;

@end
