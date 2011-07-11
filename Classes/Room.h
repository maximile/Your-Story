//
//  Room.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Layer.h"

@interface Room : NSObject {
	mapSize size;

	TileMap *mainMap;
	Layer *mainLayer;

	TileMap *bgMap;
	Layer *bgLayer;
	float bgParallax;
	
	NSMutableDictionary *maps;
}


@property mapSize size;
@property (readonly) Layer *mainLayer;
@property (readonly) Layer *bgLayer;

- (TileMap *)getMap:(NSString *)mapName;
- (id)initWithName:(NSString *)roomName;

@end
