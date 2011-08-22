#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "Sprite.h"

@interface Jumper : PhysicsObject {
	Sprite *sprite;
	cpShape *shape;
	
	GroundingContext grounding;
	double lastJumpTime;
}

- (void)shotFrom:(cpVect)shotLocation;

@end
