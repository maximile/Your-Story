#import <Cocoa/Cocoa.h>
#import "chipmunk.h"
#import "Item.h"

@interface PhysicsObject : Item {
	cpBody *body;
}

@property cpVect position;

@end
