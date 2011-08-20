#import <Cocoa/Cocoa.h>
#import "Types.h"


// Class to store the collision shape data that matches a tile
@interface CollisionShape : NSObject {
	mapCoords tile;
	pixelCoords *shapeVerts;
	int shapeVertCount;
}

@property (readonly) mapCoords tile;
@property (readonly) pixelCoords *shapeVerts;
@property (readonly) int shapeVertCount;

- (id)initWithTile:(mapCoords)newMapCoords shapeString:(NSString *)string;

@end


// General class to store collision data, and get a matching collision shape for a given tile
@interface Collision : NSObject {	
	unsigned short *collisionMap;
	pixelSize collisionMapSize;
	
	NSMutableArray *shapes;
}

@property (readonly) unsigned short *collisionMap;
@property (readonly) pixelSize collisionMapSize;

+ (Collision *)collision;
+ (mapCoords)shapeForCoords:(mapCoords)coords data:(unsigned short *)data dataSize:(pixelSize)dataSize;
- (CollisionShape *)shapeForTile:(mapCoords)coords;

@end


