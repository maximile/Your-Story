#import "Character.h"
#import "Jumper.h"
#import "Texture.h"
#import "DamageArea.h"
#import "Game+Items.h"

#define PLAYER_VELOCITY 100.0

#define PLAYER_GROUND_ACCEL_TIME 0.05
#define PLAYER_GROUND_ACCEL (PLAYER_VELOCITY/PLAYER_GROUND_ACCEL_TIME)

#define PLAYER_AIR_ACCEL_TIME 0.25
#define PLAYER_AIR_ACCEL (PLAYER_VELOCITY/PLAYER_AIR_ACCEL_TIME)

#define JUMP_HEIGHT 16.0
#define JUMP_BOOST_HEIGHT 24.0
#define FALL_VELOCITY 250.0

#define HEAD_FRICTION 0.7

@implementation Character

static void
SelectPlayerGroundNormal(cpBody *body, cpArbiter *arb, struct CharacterGroundingContext *grounding){
	CP_ARBITER_GET_BODIES(arb, b1, b2);
	cpVect n = cpvneg(cpArbiterGetNormal(arb, 0));
	
	if(n.y > grounding->normal.y){
		grounding->normal = n;
		grounding->penetration = -cpArbiterGetDepth(arb, 0);
		grounding->body = b2;
	}
}

static void
playerUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Character *self = cpBodyGetUserData(body);
	
	// Get the grounding information.
	self->grounding = (struct CharacterGroundingContext){cpvzero, 0.0, NULL};
	cpBodyEachArbiter(body, (cpBodyArbiterIteratorFunc)SelectPlayerGroundNormal, &self->grounding);
	
	// Reset jump boosting if you hit your head.
	if(self->grounding.normal.y < 0.0f) self->remainingBoost = 0.0f;
		
	// Target horizontal velocity used by air/ground control
	cpFloat target_vx = PLAYER_VELOCITY*((self->directionInput & RIGHT ? 1 : 0) - (self->directionInput & LEFT ? 1 : 0));
	
	// Update the surface velocity and friction
	cpVect surface_v = cpv(target_vx, 0.0);
	self->feetShape->surface_v = surface_v;
	if(self->grounding.body){
		self->feetShape->u = -PLAYER_GROUND_ACCEL/gravity.y;
		self->headShape->u = HEAD_FRICTION;
	} else {
		self->feetShape->u = self->headShape->u = 0.0;
	}
	
	// Apply air control if not grounded
	if(!self->grounding.body){
		// Smoothly accelerate the velocity
		body->v.x = cpflerpconst(body->v.x, target_vx + self->groundVelocity.x, PLAYER_AIR_ACCEL*dt);
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

- (id)initWithPosition:(pixelCoords)position {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	body->velocity_func = playerUpdateVelocity;
	
	// Make the head shape smaller so it doesn't cause friction with walls.
	// Maybe should dynamically assign friction like with the feetShape?
	headShape = cpCircleShapeNew(body, 4.0, cpv(0, 4));
	cpShapeSetFriction(headShape, 0.7);
	
	feetShape = cpCircleShapeNew(body, 4.0, cpv(0, -4));
	// feetShape = cpBoxShapeNew(body, 12, 16);
	
	cpShapeSetCollisionType(headShape, [self class]);
	cpShapeSetCollisionType(feetShape, [self class]);
	
	// drawing resources
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	walkCycle = [NSArray arrayWithObjects:@"normal", @"walk1", @"normal", @"walk2", nil];
	
	rightSprites = [NSDictionary dictionaryWithObjectsAndKeys:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 0, 16, 16)], @"normal",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 0, 16, 16)], @"jump",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(64, 0, 16, 16)], @"walk1",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 0, 16, 16)], @"walk2",
	nil];
	leftSprites = [NSDictionary dictionaryWithObjectsAndKeys:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 16, 16, 16)], @"normal",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 16, 16, 16)], @"jump",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(64, 16, 16, 16)], @"walk1",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 16, 16, 16)], @"walk2",
	nil];
	
	facing = RIGHT;
	
	return self;
}

-(cpVect)position
{
	// Correct the drawn position for overlap with the grounding object.
	return cpvadd(cpBodyGetPos(body), cpvmult(grounding.normal, grounding.penetration - COLLISION_SLOP));
}

-(pixelCoords)pixelPosition
{
	// Correct the drawn position for overlap with the grounding object.
	cpVect pos = cpvadd(cpBodyGetPos(body), cpvmult(grounding.normal, grounding.penetration - COLLISION_SLOP));
	return pixelCoordsMake(round(pos.x), round(pos.y));
}

- (void)draw {
	pixelCoords pixelPos = self.pixelPosition;
	
	if(!hurt || (hurt%9 >= 3)) {
		cpVect vel = cpBodyGetVel(body);
	
		NSString *spriteKey = nil;
		if (wellGrounded) {  // touching the floor
			if (abs(vel.x) > 1) {  // walking
				// walk frame based on x-position
				int cycleIndex = (pixelPos.x / 6) % walkCycle.count;
				if (cycleIndex < 0) cycleIndex += walkCycle.count;
				spriteKey = [walkCycle objectAtIndex:cycleIndex];
			}
			else {  // standing still
				spriteKey = @"normal";
			}
		}
		
		else {  // jumping or falling
			if (cpBodyGetVel(body).y < -20.0) {  // falling
				spriteKey = @"jump";
			}
			else {  // jumping
				spriteKey = @"normal";
			}
		}
		
		Sprite *sprite = nil;
		if (facing & LEFT) sprite = [leftSprites valueForKey:spriteKey];
		else sprite = [rightSprites valueForKey:spriteKey];
		[sprite drawAt:pixelPos];
	}
	
	[[Texture lightmapTexture] addAt:pixelPos radius:96];
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, headShape);
	cpSpaceAddShape(space, feetShape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, headShape);
	cpSpaceRemoveShape(space, feetShape);
}

- (void)update:(Game *)game {
	int jumpState = (directionInput & UP);
	
	wellGrounded = (grounding.body && cpfabs(grounding.normal.x/grounding.normal.y) < feetShape->u);
	if(wellGrounded){
		groundVelocity = grounding.body->v;
		remainingAirJumps = 1;
	}
	
	// If the jump key was just pressed this frame, jump!
	bool jump = (jumpState && !lastJumpKeyState);
	
	if(jump && (wellGrounded || remainingAirJumps)){
		cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*GRAVITY);
		body->v.y = groundVelocity.y + jump_v;
		
		remainingBoost = JUMP_BOOST_HEIGHT/jump_v;
		if(!wellGrounded) remainingAirJumps--;
	} else if(!jumpState){
		remainingBoost = 0.0;
	}
	
	lastJumpKeyState = jumpState;
	
	// face in direction of motion
	if (cpBodyGetVel(body).x < -1) facing = LEFT;
	if (cpBodyGetVel(body).x > 1) facing = RIGHT;
	// override this if the user is trying to move in a specific direction
	if (directionInput & LEFT) facing = LEFT;
	if (directionInput & RIGHT) facing = RIGHT;
	
	if (hurt > 0) hurt--; 
}

- (int)hitJumper:(Jumper *)jumper arbiter:(cpArbiter *)arb {
	if (hurt) {
		return 0;
	}
	cpVect normal = cpArbiterGetNormal(arb, 0);
	cpVect response = cpvnormalize(cpv(1.0, 1.0));
	if (normal.x > 0) response.x *= -1;
	NSLog(@"%f %f", response.x, response.y);
	cpBodySetVel(body, cpvmult(response, 280));
	hurt = 100;
	return 0;
}

- (void)finalize {
	cpShapeFree(headShape);
	cpShapeFree(feetShape);
	cpBodyFree(body);
}

- (void)shoot:(Game *)game {
	DamageArea *damage = [[DamageArea alloc] initWithPosition:self.position direction:facing];
	[game addItem:damage];
}

@end
