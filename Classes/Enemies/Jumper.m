#import "Jumper.h"
#import "Player.h"
#import "Particle.h"
#import "Game+Items.h"
#import "RandomTools.h"
#import "Sound.h"

#define JUMP_HEIGHT TILE_SIZE
#define JUMP_INTERVAL 1.5

@implementation Jumper

- (id)initWithPosition:(pixelCoords)position {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	
	shape = cpCircleShapeNew(body, 8.0, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.7);
	cpShapeSetGroup(shape, self);
	cpShapeSetUserData(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	bodySprites = [NSDictionary dictionaryWithObjectsAndKeys:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 16, 16, 16)], @"airborne",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(16, 16, 16, 16)], @"crouched",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 32, 16, 16)], @"idle",
	nil];
	eyesSprites = [NSDictionary dictionaryWithObjectsAndKeys:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(20, 32, 8, 4)], @"bl",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(20, 36, 8, 4)], @"tl",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(20, 40, 8, 4)], @"tr",
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(20, 44, 8, 4)], @"br",
	nil];
	
	gibSprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(39, 46, 1, 1)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(33, 45, 2, 2)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(36, 45, 2, 2)],
	nil];
	
	
	lastJumpTime = -INFINITY;
	health = 2;
	
	return self;
}

static inline cpFloat
cpfsign(cpFloat f)
{
	return (f > 0) - (f < 0);
}

-(void)jumpTowardsIfReady:(cpVect)target
{
	Game *game = [Game game];
	cpFloat elapsed = game.fixedTime - lastJumpTime;
	
	if(grounding.body && elapsed > JUMP_INTERVAL){
		cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*GRAVITY);
		body->v = cpvadd(grounding.body->v, cpv(cpfsign(target.x - cpBodyGetPos(body).x)*jump_v/1.5, jump_v));
		
		[Sound playSound:@"JumperJump.ogg"];
		
		lastJumpTime = game.fixedTime;
		justJumped = YES;
		aboutToJump = NO;
	}
}

- (void)update:(Game *)game {
	if (health <= 0) {
		[game removeItem:self];
		
		// death explosion
		for (Sprite *gibSprite in gibSprites) {
			ParticleCollection *gibs = [[ParticleCollection alloc] initWithCount:20 sprite:gibSprite physical:NO];
			[gibs setVelocityX:floatRangeMake(-200.0, 200.0) Y:floatRangeMake(50.0, 200.0)];
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x - 5, self.pixelPosition.x + 5) Y:floatRangeMake(self.pixelPosition.y - 5, self.pixelPosition.y - 5)];
			[gibs setLife:floatRangeMake(0.0, 0.3)];
			[game addItem:gibs];
		}
				
		return;
	}
	
	
	// Get the grounding information.
	UpdateGroundingContext(body, &grounding);
	
	// Play a sound if we landed
	if(cpfabs(self->grounding.impulse.y)*body->m_inv > 200.0) [Sound playSound:@"PlayerLand.ogg" volume:0.5 pitch:1.0];
	
	Player *player = game.player;
	cpVect playerPos = player.position;
	cpVect pos = cpBodyGetPos(body);
	
	double elapsed = game.fixedTime - lastJumpTime;
	
	// can the jumper see the player?
	canSeePlayer = NO;
	nearPlayer = cpvnear(playerPos, pos, 96);
	if (nearPlayer) {
		cpShape *hit = cpSpaceSegmentQueryFirst(game.space, pos, playerPos, CP_ALL_LAYERS, self, NULL);
		if (hit && hit->body == player.body) {
			canSeePlayer = YES;
		}
	}
	
	// no longer just jumped?
	if (justJumped && elapsed > 0.1) {
		justJumped = NO;
	}
	
	// about to jump?
	if(grounding.body && elapsed > JUMP_INTERVAL - 0.2 && canSeePlayer){
		aboutToJump = YES;
	}
	
	// should jump?
	if(canSeePlayer) [self jumpTowardsIfReady:playerPos];
}


// TODO duplicated code
-(pixelCoords)pixelPosition
{
	// Correct the drawn position for overlap with the grounding object.
	cpVect pos = cpvadd(cpBodyGetPos(body), cpvmult(grounding.normal, grounding.penetration - COLLISION_SLOP));
	return pixelCoordsMake(round(pos.x), round(pos.y));
}

- (void)draw:(Game *)game {	
	pixelCoords pixelPos = self.pixelPosition;
	pixelCoords eyePos = pixelPos;
	
	NSString *bodyKey = @"idle";
	eyePos.y = pixelPos.y - 1;
	
	if (aboutToJump) {
		bodyKey = @"crouched";
		eyePos.y = pixelPos.y - 3;
	}
	if (justJumped) {
		bodyKey = @"airborne";
		eyePos.y = pixelPos.y + 3;
	}
	Sprite *bodySprite = [bodySprites valueForKey:bodyKey];
	
	NSString *eyesKey = nil;
	if (grounding.body == NULL || (nearPlayer && fmod(game.fixedTime + self.objectPhase*5.0, 5.0) > 0.1)) {
		Player *player = [Game game].player;
		cpVect playerPos = player.position;
		cpVect pos = cpBodyGetPos(body);
		if (pos.x < playerPos.x && pos.y < playerPos.y - 4) eyesKey = @"tr";
		if (pos.x > playerPos.x && pos.y < playerPos.y - 4) eyesKey = @"tl";
		if (pos.x < playerPos.x && pos.y > playerPos.y - 4) eyesKey = @"br";
		if (pos.x > playerPos.x && pos.y > playerPos.y - 4) eyesKey = @"bl";
		
//		[[Texture lightmapTexture] addAt:pixelPos radius:16];
	}
	Sprite *eyesSprite = [eyesSprites valueForKey:eyesKey];
	
	[bodySprite drawAt:pixelPos];
	[eyesSprite drawAt:eyePos];
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, shape);
}

- (void)finalize {
	cpShapeFree(shape);
	cpBodyFree(body);
}

- (void)shotFrom:(cpVect)shotLocation damage:(float)damage;
{
	directionMask shotDirection = LEFT;
	if (shotLocation.x > self.position.x) shotDirection = RIGHT;
	
	cpVect pos = cpBodyGetPos(body);
	float strength = 100 - cpvdist(pos, shotLocation);
	cpVect effect = cpvnormalize(cpv(1.0, 0.6));
	if (shotDirection == RIGHT) {
		effect.x *= -1;
	}
	effect = cpvmult(effect, strength * 25*damage);
	cpBodyApplyImpulse(body, effect, cpvzero);
	
	[self jumpTowardsIfReady:shotLocation];
	
	// 'blood'
	for (Sprite *gibSprite in gibSprites) {
		ParticleCollection *gibs = [[ParticleCollection alloc] initWithCount:15 sprite:gibSprite physical:NO];
		if (shotDirection == LEFT) {
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x - 8, self.pixelPosition.x - 6) Y:floatRangeMake(self.pixelPosition.y - 3, self.pixelPosition.y + 3)];
			[gibs setVelocityX:floatRangeMake(-200.0, -100.0) Y:floatRangeMake(-30, 30)];
		}
		else {
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x +6, self.pixelPosition.x + 8) Y:floatRangeMake(self.pixelPosition.y - 3, self.pixelPosition.y + 3)];
			[gibs setVelocityX:floatRangeMake(100.0, 200.0) Y:floatRangeMake(-30, 30)];
		}
		[gibs setLife:floatRangeMake(0.0, 0.3)];
		[[Game game] addItem:gibs];
	}
	
	health -= damage;
}

@end
