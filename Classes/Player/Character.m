#import "Character.h"
#import "Jumper.h"
#import "Texture.h"
#import "Bullet.h"
#import "Game+Items.h"
#import "Particle.h"
#import "RandomTools.h"
#import "Sound.h"
#import "Health.h"
#import "Battery.h"
#import "DoubleJump.h"
#import "Shotgun.h"
#import "Font.h"
#import "Message.h"
#import "Coin.h"


#define PLAYER_VELOCITY 100.0

#define PLAYER_GROUND_ACCEL_TIME 0.05
#define PLAYER_GROUND_ACCEL (PLAYER_VELOCITY/PLAYER_GROUND_ACCEL_TIME)

#define PLAYER_AIR_ACCEL_TIME 0.25
#define PLAYER_AIR_ACCEL (PLAYER_VELOCITY/PLAYER_AIR_ACCEL_TIME)

#define JUMP_HEIGHT 16.0
#define JUMP_BOOST_HEIGHT 24.0
#define FALL_VELOCITY 250.0

#define JUMP_LENIENCY 0.05

#define HEAD_FRICTION 0.7

#define MAX_HEALTH 8

@implementation Character

@synthesize battery;

static void
playerUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	Character *self = cpBodyGetUserData(body);
	
	// Get the grounding information.
	UpdateGroundingContext(body, &self->grounding);
	
	// Play a sound if we landed
	if(cpfabs(self->grounding.impulse.y)*body->m_inv > 200.0) [Sound playSound:@"PlayerLand.ogg" volume:0.5 pitch:1.0];
	
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
	int jumpState = self->jumpInput;
	cpBool boost = (jumpState && self->remainingBoost > 0.0f);
	cpBodyUpdateVelocity(body, (boost ? cpvzero : gravity), damping, dt);
	
	// Decrement the jump boosting
	self->remainingBoost -= dt;
	
	// TODO does it make sense to have an upwards limit?
	body->v.y = cpfclamp(body->v.y, -FALL_VELOCITY, INFINITY);
}

- (void)updateStateDict:(NSMutableDictionary *)stateDict {
	[stateDict setValue:[NSNumber numberWithInt:health] forKey:@"health"];
	[stateDict setValue:[NSNumber numberWithBool:canDoubleJump] forKey:@"doubleJump"];
}

- (id)initWithPosition:(pixelCoords)position state:(NSDictionary *)state {
	if ([super initWithPosition:position state:state]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	body->velocity_func = playerUpdateVelocity;
	
	headShape = cpCircleShapeNew(body, 3.0, cpv(0, 4));
	cpShapeSetCollisionType(headShape, [self class]);
	cpShapeSetGroup(headShape, self);
	cpShapeSetUserData(headShape, self);
	
	feetShape = cpCircleShapeNew(body, 4.0, cpv(0, -4));
	cpShapeSetCollisionType(feetShape, [self class]);
	cpShapeSetGroup(feetShape, self);
	cpShapeSetUserData(feetShape, self);
	
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
	
	fullHealth = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(3, 51, 11, 10)];
	emptyHealth = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(19, 51, 11, 10)];
	
	shotgunParticleSprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(33, 33, 2, 2)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(36, 33, 3, 2)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(40, 33, 1, 1)],
	nil];
	smokeParticleSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(42, 33, 1, 1)];
	
	facing = RIGHT;
	health = MAX_HEALTH;
	battery = 1.0;
	
	health = [[state valueForKey:@"health"] intValue];
	canDoubleJump = [[state valueForKey:@"doubleJump"] boolValue];
	
	return self;
}

- (void)addHealth:(int)healthDiff {
	health += healthDiff;
	if (health < 0) health = 0;
	if (health > MAX_HEALTH) health = MAX_HEALTH;
}

- (cpVect)position
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

- (void)draw:(Game *)game {
	pixelCoords pixelPos = self.pixelPosition;
	
	if(invulnerable == 0.0 || (fmod(invulnerable, 0.05) >= 0.02)) {
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
	
	float lightPower = battery * 120.0;
	// flicker when running out
	BOOL drawLight = YES;
	if (battery < 0.3) {
		if ((cpfsin(18.0 * game.fixedTime) + 1.0) / 2.0 > (battery / 0.3)) {
			drawLight = NO;
		}
	}
	if (drawLight && game.currentRoom.ambientLight < 0.5) {
		float radius = cpflerp(lightPower * 0.95, lightPower * 1.05, cpfsin(3.0*game.fixedTime)*0.5 + 0.5);
		[[Texture lightmapTexture] addAt:pixelPos radius:radius];
	}
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
	
	// sort of a hack, but need to stop the loop when changing rooms
}

- (void)update:(Game *)game {
	int jumpState = jumpInput;
	remainingJumpLeniency -= FIXED_DT;
	
	wellGrounded = (grounding.body && cpfabs(grounding.normal.x/grounding.normal.y) < feetShape->u);
	if(wellGrounded){
		groundVelocity = grounding.body->v;
		remainingAirJumps = (canDoubleJump ? 1 : 0);
		remainingJumpLeniency = JUMP_LENIENCY;
	}
	
	// If the jump key was just pressed this frame, jump!
	bool jump = (jumpState && !lastJumpKeyState);
	
	if(jump && (wellGrounded || remainingAirJumps || (remainingJumpLeniency > 0))){
		cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*GRAVITY);
		body->v.y = groundVelocity.y + jump_v;
		
		remainingBoost = JUMP_BOOST_HEIGHT/jump_v;
		
		[Sound playSound:@"PlayerJump.ogg"];
		
		if(!wellGrounded && (remainingJumpLeniency <= 0)) {  // was a double jump
			remainingAirJumps--;
			
			// if the player is holding a direction while double jumping, jump in that direction
			// TODO, need to take grounding velocity into account?
			if (directionInput & LEFT) body->v.x = -PLAYER_VELOCITY;
			if (directionInput & RIGHT) body->v.x = PLAYER_VELOCITY;
			if (directionInput & LEFT & RIGHT) body->v.x = 0;  // unlikely
			
			// smoke particles for double jump
			ParticleCollection *smoke = [[ParticleCollection alloc] initWithCount:8 sprite:smokeParticleSprite physical:NO];
			[smoke setVelocityX:floatRangeMake(-10.0, 10.0) Y:floatRangeMake(-20.0, -150.0)];
			[smoke setPositionX:floatRangeMake(self.pixelPosition.x - 3, self.pixelPosition.x + 3) Y:floatRangeMake(self.pixelPosition.y - 8, self.pixelPosition.y - 8)];
			[smoke setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(180.0, 220.0)];
			[smoke setDamping:floatRangeMake(0.8, 0.8)];
			[smoke setLife:floatRangeMake(0.3, 0.5)];
			[game addItem:smoke];
		}
			
	} else if(!jumpState){
		remainingBoost = 0.0;
	}
	
	lastJumpKeyState = jumpState;
	
	// face in direction of motion
//	if (cpBodyGetVel(body).x < -1) facing = LEFT;
//	if (cpBodyGetVel(body).x > 1) facing = RIGHT;
	// override this if the user is trying to move in a specific direction
	if (directionInput & LEFT) facing = LEFT;
	if (directionInput & RIGHT) facing = RIGHT;
	
	if (invulnerable > 0) invulnerable = cpfmax(0.0, invulnerable - FIXED_DT);
	if (reloadTime > 0) reloadTime = cpfmax(0.0, reloadTime - FIXED_DT);
	
	if (health <= 0) {
		game.player = nil;
		[game removeItem:self];
	}
	
	if (game.currentRoom.ambientLight < 0.5) {
		// dark room? use torch
		battery -= 0.0003;
		if (battery < 0.0) {
			game.player = nil;
			[game removeItem:self];
		}
	}
}

- (int)hitEnemy:(PhysicsObject *)enemy arbiter:(cpArbiter *)arb;
{
	if (invulnerable > 0.0) {
		return 0;
	}
	
	[Sound playSound:@"PlayerHit.ogg"];
	
	cpVect normal = cpArbiterGetNormal(arb, 0);
	cpVect response = cpvnormalize(cpv(1.0, 1.0));
	if (normal.x > 0) response.x *= -1;
	NSLog(@"%f %f", response.x, response.y);
	cpBodySetVel(body, cpvmult(response, 280));
	invulnerable = 2.0;
	
	if ([enemy isKindOfClass:[Jumper class]])
		[self addHealth:-2];
	else
		[self addHealth:-1];
	
	return 0;
}

- (int)hitPickup:(Pickup *)pickup arbiter:(cpArbiter *)arb {
	if (pickup.used) return 0;
	
	if ([pickup isKindOfClass:[Health class]]) {
		if (health == MAX_HEALTH) return 0;
		[self addHealth:1];
		[Sound playSound:@"Heart.ogg"];
	}
	
	if ([pickup isKindOfClass:[Battery class]]) {
		battery = 1.0;
		[Sound playSound:@"Heart.ogg"];
	}

	if ([pickup isKindOfClass:[DoubleJump class]]) {
		canDoubleJump = YES;
		[Sound playSound:@"Heart.ogg"];
	}
	
	if ([pickup isKindOfClass:[Coin class]]) {
		[Game game].coinCount = [Game game].coinCount + 1;
		[Sound playSound:@"Heart.ogg"];
	}
	
	if([pickup isKindOfClass:[Shotgun class]]){
		useShotgun = TRUE;
	}
	
	// mark the health item as used so that it doesn't get applied twice
	// if the head and feet both touch it
	[[Game game] removeItem:pickup];
	pickup.used = YES;
	
	// add pickup message
	NSString *messageString = pickup.title;
	if (messageString.length > 0) {
		pixelCoords messagePos = pixelCoordsMake(pickup.startingPosition.x, pickup.startingPosition.y + 18);
		Font *messageFont = [Font fontNamed:@"Geneva9"];
		Message *newMessage = [[Message alloc] initWithPosition:messagePos font:messageFont string:messageString];
		newMessage.alignment = NSCenterTextAlignment;
		newMessage.life = 4.0;
		[[Game game] addItem:newMessage];
	}
	
	return 0;
}

- (void)finalize {
	cpShapeFree(headShape);
	cpShapeFree(feetShape);
	cpBodyFree(body);
	[super finalize];
}

- (void)fireShotgun:(Game *)game
{
	if (shellsFired%2==0 && reloadTime > 0) return;
	
	// hard coded shotgun blast
	cpFloat baseAngle = (facing & RIGHT ? 0.0 : M_PI);
	for(int i=0; i<5; i++){
		cpFloat jitter = (cpFloat)rand()/(cpFloat)RAND_MAX;
		cpVect velocity = cpvmult(cpvforangle(baseAngle + (jitter*2.0 - 1.0)*0.2), 600);
		
		Bullet *ray = [[Bullet alloc] initWithPosition:self.position velocity:velocity distance:100 damage:0.2];
		ray.group = self;
		ray.startTime = game.fixedTime + FIXED_DT*(2.0 - ((double)rand()/(double)RAND_MAX));
		[game addItem:ray];
	}
	
	[Sound playSound:@"PlayerShotgun.ogg"];
	
	// add particles
	pixelCoords muzzleLoc = self.pixelPosition;
	muzzleLoc.x += (facing & LEFT) ? -5 : 5;
	muzzleLoc.y -= 3;
	
	for (Sprite *particleSprite in shotgunParticleSprites) {
		ParticleCollection *p = [[ParticleCollection alloc] initWithCount:10 sprite:particleSprite physical:NO];
		[p setPositionX:floatRangeMake(muzzleLoc.x, muzzleLoc.x) Y:floatRangeMake(muzzleLoc.y-1, muzzleLoc.y+1)];
		if (facing & LEFT)
			[p setVelocityX:floatRangeMake(-600.0, -300.0) Y:floatRangeMake(-50.0, 50.0)];
		else
			[p setVelocityX:floatRangeMake(300.0, 600.0) Y:floatRangeMake(-50.0, 50.0)];
		[p setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(-300.0, 300.0)];
		[p setDamping:floatRangeMake(0.9, 0.95)];
		[p setLife:floatRangeMake(0.0, 0.3)];
		[game addItem:p];
	}
	
	ParticleCollection *smoke = [[ParticleCollection alloc] initWithCount:10 sprite:smokeParticleSprite physical:NO];
	if (facing & LEFT)
		[smoke setVelocityX:floatRangeMake(-600.0, -300.0) Y:floatRangeMake(-100.0, 100.0)];
	else
		[smoke setVelocityX:floatRangeMake(300.0, 600.0) Y:floatRangeMake(-100.0, 100.0)];
	
	[smoke setPositionX:floatRangeMake(muzzleLoc.x, muzzleLoc.x) Y:floatRangeMake(muzzleLoc.y, muzzleLoc.y)];
	[smoke setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(500.0, 700.0)];
	[smoke setDamping:floatRangeMake(0.8, 0.8)];
	[smoke setLife:floatRangeMake(0.4, 0.7)];
	[game addItem:smoke];
	
	[[Texture lightmapTexture] addAt:self.pixelPosition radius:250];
	
	reloadTime = 1.0;
	shellsFired++;
}

- (void)firePistol:(Game *)game
{
	cpVect velocity = (facing & RIGHT ? cpv(600.0, 0.0) : cpv(-600.0, 0.0));
	Bullet *ray = [[PistolBullet alloc] initWithPosition:self.position velocity:velocity distance:150 damage:0.2];
	ray.group = self;
	[game addItem:ray];
	
	[Sound playSound:@"PlayerPistol.ogg"];
	
	[[Texture lightmapTexture] addAt:self.pixelPosition radius:100];
}

- (void)shoot:(Game *)game {
	if(useShotgun){
		[self fireShotgun:game];
	} else {
		[self firePistol:game];
	}
}

- (void)drawStatus {
	for (int i = 0; i < MAX_HEALTH; i++) {
		pixelCoords iconLoc = pixelCoordsMake(i*12 + 12, 12);
		if (i < health) [fullHealth drawAt:iconLoc];
		else [emptyHealth drawAt:iconLoc];
	}
	int coinCount = [Game game].coinCount;
	NSString *coinsString = [NSString stringWithFormat:@"%i of %i coins", coinCount, 8];
	[[Font fontNamed:@"Chicago12"] drawString:coinsString at:pixelCoordsMake(CANVAS_SIZE.width - 8, 6) alignment:NSRightTextAlignment];
}

@end
