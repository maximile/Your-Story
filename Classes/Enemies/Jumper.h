#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "Sprite.h"

@interface Jumper : PhysicsObject {
	NSDictionary *bodySprites;
	NSDictionary *eyesSprites;
	NSArray *gibSprites;

	cpShape *shape;
	
	GroundingContext grounding;
	double lastJumpTime;
	BOOL aboutToJump;	
	BOOL justJumped;
	
	BOOL nearPlayer;
	BOOL canSeePlayer;
	
	float health;
}

@end
