#import "PhysicsObject.h"

void
GroundingContextCallback(cpBody *body, cpArbiter *arb, GroundingContext *grounding){
	CP_ARBITER_GET_BODIES(arb, b1, b2);
	cpVect n = cpvneg(cpArbiterGetNormal(arb, 0));
	
	if(n.y > grounding->normal.y){
		grounding->normal = n;
		grounding->penetration = -cpArbiterGetDepth(arb, 0);
		grounding->body = b2;
	}
}

void
UpdateGroundingContext(cpBody *body, GroundingContext *context)
{
	(*context) = (GroundingContext){cpvzero, 0.0, NULL};
	cpBodyEachArbiter(body, (cpBodyArbiterIteratorFunc)GroundingContextCallback, context);
}


@implementation PhysicsObject

@synthesize body;

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
