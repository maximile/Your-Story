//
//  Collision.h
//  Your Story
//
//  Created by Max Williams on 17/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CollisionShape : NSObject {
	tileCoords tile;
	tileCoords *shapeVerts;
	int shapeVertCount;
}

@property (readonly) tileCoords tile;
@property (readonly) tileCoords *shapeVerts;
@property (readonly) int shapeVertCount;

- (id)initWithTile:(tileCoords)newTileCoords shapeString:(NSString *)string;

@end

@interface Collision : NSObject {
	unsigned short *collisionMap;
	int width;
	int height;
	
	NSMutableArray *shapes;
}

@property (readonly) unsigned short *collisionMap;
@property (readonly) int width;
@property (readonly) int height;

+ (Collision *)collision;
// + (void)generateCollisionFromData:(unsigned short *)data width:(int)width height:(int)height;
+ (CollisionShape *)shapeForCoords:(tileCoords)coords data:(unsigned short *)data dataSize:(mapSize)dataSize;
- (CollisionShape *)shapeForTile:(tileCoords)coords;

@end
