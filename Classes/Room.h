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
	TileMap *midMap;
	Layer *midLayer;
}

- (id)initWithName:(NSString *)roomName;
- (void)draw;

@end
