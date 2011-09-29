#import "Particle.h"
#import "RandomTools.h"
#import "Game+Items.h"
#define DENSITY 0.05

@implementation ParticleCollection

static void particleUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt) {
	particle *p = cpBodyGetUserData(body);
	cpBodyUpdateVelocity(body, p->gravity, p->damping, dt);
}

- (id)initWithCount:(int)newCount sprite:(Sprite *)newSprite physical:(BOOL)newPhysical {
	if ([super init] == nil) return nil;
	
	particleCount = newCount;
	sprite = newSprite;
	physical = newPhysical;
	
	float spriteRadius = (sprite.size.width + sprite.size.height) / 4.0;
	
	particles = calloc(particleCount, sizeof(particle));
	for (int i=0; i<particleCount; i++) {
		particle p;
		p.inSpace = NO;
		p.body = cpBodyNew(spriteRadius * spriteRadius * M_PI, INFINITY);
		p.body->velocity_func = particleUpdateVelocity;
		
		if (physical) {
			p.shape = cpCircleShapeNew(p.body, spriteRadius, cpvzero);
		}
		
		particles[i] = p;
		cpBodySetUserData(p.body, &particles[i]);
	}
	
	// set defaults
	[self setLife:floatRangeMake(1.0, 1.0)];
	[self setDamping:floatRangeMake(1.0, 1.0)];
	[self setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(-GRAVITY, -GRAVITY)];
	
	return self;
}

- (void)setDamping:(floatRange)newDamping {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		p.damping = randomFloat(newDamping.min, newDamping.max);
		particles[i] = p;
	}
}

- (void)setGravityX:(floatRange)x Y:(floatRange)y {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		cpVect newGravity = cpvzero;
		newGravity.x = randomFloat(x.min, x.max);
		newGravity.y = randomFloat(y.min, y.max);
		p.gravity = newGravity;
		particles[i] = p;
	}
}

- (void)setPositionX:(floatRange)x Y:(floatRange)y {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		cpVect newPos = cpvzero;
		newPos.x = randomFloat(x.min, x.max);
		newPos.y = randomFloat(y.min, y.max);
		p.body->p = (relativeBody ? cpBodyLocal2World(relativeBody, newPos) : newPos);
		particles[i] = p;
	}
}

- (void)setVelocityX:(floatRange)x Y:(floatRange)y {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		cpVect newVel = cpvzero;
		newVel.x = randomFloat(x.min, x.max);
		newVel.y = randomFloat(y.min, y.max);
		p.body->v = (relativeBody ? cpvrotate(p.body->rot, newVel) : newVel);
		particles[i] = p;
	}
}

- (void)setLife:(floatRange)newLife {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		p.life = randomFloat(newLife.min, newLife.max);
		particles[i] = p;
	}
}

-(void)setRelativeToBody:(cpBody *)theBody;
{
	relativeBody = theBody;
}
	

- (void)update:(Game *)game {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		if (p.inSpace == NO) continue;
		p.life -= FIXED_DT;
		if (p.life <= 0) {
			p.inSpace = NO;
			cpSpaceRemoveBody(game.space, p.body);
			if (physical) cpSpaceRemoveShape(game.space, p.shape);
		}
		particles[i] = p;
	}
}

- (void)addToSpace:(cpSpace *)space {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		cpSpaceAddBody(space, p.body);
		p.inSpace = YES;
		if (physical)
			cpSpaceAddShape(space, p.shape);
		particles[i] = p;
	}
}

- (void)removeFromSpace:(cpSpace *)space {
	// remove any remaining particles from the space
	for (int i=0; i<particleCount; i++) {		
		particle p = particles[i];
		if (p.inSpace == NO) continue;
		cpSpaceRemoveBody(space, p.body);
		p.inSpace = NO;
		if (physical)
			cpSpaceRemoveShape(space, p.shape);
		particles[i] = p;
	}
}

- (void)draw:(Game *)game {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		if (p.inSpace == NO) continue;
		[sprite drawAt:pixelCoordsMake(p.body->p.x, p.body->p.y)];
	}
}

- (void)finalize {
	for (int i=0; i<particleCount; i++) {
		particle p = particles[i];
		if (physical) {
			cpShapeFree(p.shape);
		}
		cpBodyFree(p.body);
	}
	free(particles);	
	
	[super finalize];
}

@end
