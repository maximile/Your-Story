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
SelectPlayerGroundNormal(cpBody *body, cpArbiter *arb, cpVect *groundNormal){
	cpVect n = cpvneg(cpArbiterGetNormal(arb, 0));
	
	if(n.y > groundNormal->y){
		(*groundNormal) = n;
	}
}

static void
playerUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Character *self = cpBodyGetUserData(body);
	
	// Grab the grounding normal from last frame
	cpVect groundNormal = cpvzero;
	cpBodyEachArbiter(body, (cpBodyArbiterIteratorFunc)SelectPlayerGroundNormal, &groundNormal);
	
	self->grounded = (groundNormal.y > 0.0);
	
	// Reset jump boosting if you hit your head.
	if(groundNormal.y < 0.0f) self->remainingBoost = 0.0f;
	
	// Target horizontal velocity used by air/ground control
	cpFloat target_vx = PLAYER_VELOCITY*((self->directionInput & RIGHT ? 1 : 0) - (self->directionInput & LEFT ? 1 : 0));
	
	// Update the surface velocity and friction
	cpVect surface_v = cpv(target_vx, 0.0);
	self->feetShape->surface_v = surface_v;
	self->feetShape->u = (self->grounded ? -PLAYER_GROUND_ACCEL/gravity.y : 0.0);
	
	// Apply air control if not grounded
	if(!self->grounded){
		// Smoothly accelerate the velocity
		body->v.x = cpflerpconst(body->v.x, target_vx, PLAYER_AIR_ACCEL*dt);
	}
	
	// Perform a normal-ish update
	int jumpState = (self->directionInput & UP);
	cpBool boost = (jumpState && self->remainingBoost > 0.0f);
	cpBodyUpdateVelocity(body, (boost ? cpvzero : gravity), damping, dt);
	
	// Decrement the jump boosting
	self->remainingBoost -= dt;
	
	// TODO does it make sense to have an upwards limit?
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

- (void)update {
	int jumpState = (self->directionInput & UP);
	
	// TODO gravity getting hack
	cpVect gravity = cpSpaceGetGravity(body->CP_PRIVATE(space));
	
	// If the jump key was just pressed this frame, jump!
	if(jumpState && !lastJumpState && grounded){
		cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*-gravity.y);
		body->v = cpvadd(body->v, cpv(0.0, jump_v));
		
		remainingBoost = JUMP_BOOST_HEIGHT/jump_v;
	} else if(!jumpState){
		remainingBoost = 0.0;
	}
	
	self->lastJumpState = jumpState;
}

- (void)finalize {
	cpShapeFree(feetShape);
	cpBodyFree(body);
}

@end
