#import "Particle.h"
#import "Game+Items.h"
#define DENSITY 0.05



@implementation Particle

static void particleUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt) {
	Particle *self = cpBodyGetUserData(body);
	cpBodyUpdateVelocity(body, self.gravity, self.damping, dt);
}

@synthesize physical, life, damping, gravity;

- (id)initAt:(pixelCoords)position sprite:(Sprite *)newSprite physical:(BOOL)newPhysical {
	if ([super init] == nil) return nil;
	
	sprite = newSprite;
	physical = newPhysical;
	
	life = 1.0;
	damping = 1.0;
	gravity = cpv(0.0, -GRAVITY);
	float radius = (sprite.size.width + sprite.size.height) / 4.0;

	body = cpBodyNew(M_PI * radius * radius * DENSITY, INFINITY);
	body->velocity_func = particleUpdateVelocity;
	cpBodySetUserData(body, self);
	cpBodySetPos(body, cpv(position.x, position.y));
	if (physical) {
		shape = cpCircleShapeNew(body, radius, cpvzero);
	}
	
	return self;
}

- (void)update:(Game *)game {
	life -= FIXED_DT;
	if (life <= 0.0) {
		[game removeItem:self];
	}
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	if (physical) {
		cpSpaceAddShape(space, shape);
	}
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	if (physical) {
		cpSpaceRemoveShape(space, shape);
	}
}

- (void)draw {
	[sprite drawAt:self.pixelPosition];
}

- (void)finalize {
	if (physical) {
		cpShapeFree(shape);
	}
	cpBodyFree(body);
	[super finalize];
}

@end
