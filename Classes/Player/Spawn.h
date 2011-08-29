#import <Cocoa/Cocoa.h>
#import "Item.h"

@interface Spawn : Item {
	directionMask edge;
}

@property (readonly) directionMask edge;

+ (Spawn *)getSpawnForEdge:(directionMask)testEdge spawns:(NSArray *)spawns;

@end
