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
	int width;
	int height;
	tileCoords *tiles;
	TileMap *map;
}

- (id)initWithString:(NSString *)string map:(TileMap *)newMap;
- (void)draw;

@end
