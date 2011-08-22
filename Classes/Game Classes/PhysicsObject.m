#import "PhysicsObject.h"

@implementation PhysicsObject

- (void)addToSpace:(cpSpace *)space {}
- (void)removeFromSpace:(cpSpace *)space {}

-(pixelCoords) pixelPosition {
	cpVect pos = cpBodyGetPos(body);
	return pixelCoordsMake(pos.x, pos.y);
}

- (cpVect)position {
	return cpBodyGetPos(body);
}
- (void)setPosition:(cpVect)newPosition {
	cpBodySetPos(body, newPosition);
}

@end
