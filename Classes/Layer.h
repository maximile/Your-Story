//
//  Layer.h
//  Your Story
//
//  Created by Max Williams on 03/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TileMap.h"

@interface Layer : NSObject {
	mapSize size;
	tileCoords *tiles;
	TileMap *map;
	float parallax;
}

@property mapSize size;
@property float parallax;

- (id)initWithString:(NSString *)string map:(TileMap *)newMap;
- (id)initWithString:(NSString *)string map:(TileMap *)newMap parallax:(float)newParallax;
- (void)draw;

@end
