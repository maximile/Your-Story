#import <Cocoa/Cocoa.h>
#import "chipmunk.h"
#import "GameObject.h"

@interface PhysicsObject : GameObject {
	cpBody *body;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

@property cpVect position;

@end
