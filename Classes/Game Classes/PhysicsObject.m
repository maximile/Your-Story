#import "PhysicsObject.h"

@implementation PhysicsObject

- (void)addToSpace:(cpSpace *)space {}
- (void)removeFromSpace:(cpSpace *)space {}

- (cpVect)position {
	return cpBodyGetPos(body);
}
- (void)setPosition:(cpVect)newPosition {
	cpBodySetPos(body, newPosition);
}

@end
