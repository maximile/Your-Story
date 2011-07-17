//
//  Constants.h
//  Your Story
//
//  Created by Max Williams on 11/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#define TILE_SIZE 16
#define CANVAS_WIDTH 240
#define CANVAS_HEIGHT 180

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
