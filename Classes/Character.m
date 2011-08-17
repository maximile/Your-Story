#import "Character.h"
#import "Texture.h"


#define PLAYER_VELOCITY 200.0

#define PLAYER_GROUND_ACCEL_TIME 0.1
#define PLAYER_GROUND_ACCEL (PLAYER_VELOCITY/PLAYER_GROUND_ACCEL_TIME)

#define PLAYER_AIR_ACCEL_TIME 0.25
#define PLAYER_AIR_ACCEL (PLAYER_VELOCITY/PLAYER_AIR_ACCEL_TIME)

#define JUMP_HEIGHT 16.0
#define JUMP_BOOST_HEIGHT 18.0
#define FALL_VELOCITY 900.0
//#define GRAVITY 2000.0


@implementation Character

static void
playerUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Character *self = cpBodyGetUserData(body);
	
	cpBool boost = ((self->directionInput & UP) && self->remainingBoost > 0.0f);
	cpVect g = (boost ? cpvzero : gravity);
	cpBodyUpdateVelocity(body, g, damping, dt);
	
	body->v.y = cpfclamp(body->v.y, -FALL_VELOCITY, INFINITY);
}

- (id)init {
	if ([super init]==nil) return nil;
	
	lastJumpState = TRUE;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetUserData(body, self);
	body->velocity_func = playerUpdateVelocity;
	
	feetShape = cpCircleShapeNew(body, 8.0, cpvzero);
//	feetShape = cpBoxShapeNew(body, 16, 16);
	cpShapeSetFriction(feetShape, 1.5);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 0, 32, 16)];
	
	return self;
}

- (void)draw {
	cpVect pos = self.position;
	float angle = cpBodyGetAngle(body);
	
	// discrete steps
	angle /= (M_PI*2);
	angle *= 72.0;
	angle = round(angle);
	angle /= 72.0;
	angle *= (M_PI*2);

	[sprite drawAt:pixelCoordsMake(pos.x, pos.y) angle:angle];
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, feetShape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, feetShape);
}

static void
SelectPlayerGroundNormal(cpBody *body, cpArbiter *arb, cpVect *groundNormal){
	cpVect n = cpvneg(cpArbiterGetNormal(arb, 0));
	
	if(n.y > groundNormal->y){
		(*groundNormal) = n;
	}
}

- (void)update {
	// TODO get rid of this magic number
	cpFloat dt = 1.0/60.0;
	
	// TODO weird hack to get the gravity value
	cpFloat gravity = -cpSpaceGetGravity(body->CP_PRIVATE(space)).y;
	
	int jumpState = (directionInput & UP);
	
	// Grab the grounding normal from last frame
	cpVect groundNormal = cpvzero;
	cpBodyEachArbiter(body, (cpBodyArbiterIteratorFunc)SelectPlayerGroundNormal, &groundNormal);
	
	cpBool grounded = (groundNormal.y > 0.0);
	cpFloat target_vx = PLAYER_VELOCITY*((directionInput & RIGHT ? 1 : 0) - (directionInput & LEFT ? 1 : 0));
	
	// Update the surface velocity and friction
	cpVect surface_v = cpv(target_vx, 0.0);
	feetShape->surface_v = surface_v;
	feetShape->u = (grounded ? PLAYER_GROUND_ACCEL/gravity : 0.0);
	
	// Apply air control if not grounded
	if(!grounded){
		// Smoothly accelerate the velocity
		body->v.x = cpflerpconst(body->v.x, target_vx, PLAYER_AIR_ACCEL*dt);
	}
	
	// If the jump key was just pressed this frame, jump!
	if(jumpState && !lastJumpState && grounded){
		cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*gravity);
		body->v = cpvadd(body->v, cpv(0.0, jump_v));
		
		remainingBoost = JUMP_BOOST_HEIGHT/jump_v;
	}
	
	// Decrement the jump boosting or reset it if you bump your head.
	remainingBoost -= dt;
	if(groundNormal.y < 0.0f) remainingBoost = 0.0f;
	
	lastJumpState = jumpState;
}

- (void)finalize {
	cpShapeFree(feetShape);
	cpBodyFree(body);
}

@end
