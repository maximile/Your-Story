#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "Sprite.h"

@interface Jumper : PhysicsObject {
	NSDictionary *bodySprites;
	NSDictionary *eyesSprites;
	cpShape *shape;
	
	GroundingContext grounding;
	double lastJumpTime;
	BOOL aboutToJump;	
	BOOL justJumped;	
	BOOL canSeePlayer;
	
	int health;
}

- (void)shotFrom:(cpVect)shotLocation;

@end
