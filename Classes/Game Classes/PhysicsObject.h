#import <Cocoa/Cocoa.h>
#import "chipmunk.h"
#import "Item.h"

@interface PhysicsObject : Item {
	cpBody *body;
}

@property(readonly) pixelCoords pixelPosition;
@property cpVect position;

@end
