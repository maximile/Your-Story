#import "Rocket.h"
#import "Game+Items.h"
#import "Particle.h"
#import "RandomTools.h"
#import "Sound.h"

@implementation Rocket

static void rocketUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt) {
//	Rocket *r = cpBodyGetUserData(body);
	
	cpBodyUpdateVelocity(body, cpvmult(gravity, 0.5), 0.985, dt);
}

- (id)initWithPosition:(pixelCoords)position state:(NSDictionary *)state {
	if ([self initWithPosition:position] == nil) return nil;
	
	return self;
}

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	float mass = 150.0;
	float moment = 0.0;
	
	cpVect mainVerts[6];
	// start at bottom left
	mainVerts[0] = cpv(-24, -16);
	mainVerts[1] = cpv(-24, 16);
	mainVerts[2] = cpv(-8, 32);
	mainVerts[3] = cpv(8, 32);
	mainVerts[4] = cpv(24, 16);
	mainVerts[5] = cpv(24, -16);
	moment += cpMomentForPoly(mass * 0.8, 6, mainVerts, cpvzero);
	
	cpVect coneVerts[4];
	// start at bottom left
	coneVerts[0] = cpv(-16, -32);
	coneVerts[1] = cpv(-8, -16);
	coneVerts[2] = cpv(8, -16);
	coneVerts[3] = cpv(16, -32);
	moment += cpMomentForPoly(mass * 0.2, 4, coneVerts, cpvzero);
	
	body = cpBodyNew(mass, moment);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	body->velocity_func = rocketUpdateVelocity;

	mainShape = cpPolyShapeNew(body, 6, mainVerts, cpvzero);
	coneShape = cpPolyShapeNew(body, 4, coneVerts, cpvzero);
	cpShapeSetFriction(mainShape, 0.0);
	cpShapeSetFriction(coneShape, 0.7);
	
	staticBody = cpBodyNewStatic();
	rotaryLimit = cpRotaryLimitJointNew(body, staticBody, -0.5, 0.5);
	
	Texture *texture = [Texture textureNamed:@"MainSprites"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 64, 48, 64)];
	
	exhaustSprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(64, 96, 7, 6)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(72, 96, 5, 6)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(65, 104, 5, 4)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(72, 104, 5, 5)],
	nil];
	
	return self;
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, mainShape);
	cpSpaceAddShape(space, coneShape);
	cpSpaceAddConstraint(space, rotaryLimit);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, mainShape);
	cpSpaceRemoveShape(space, coneShape);
	cpSpaceRemoveConstraint(space, rotaryLimit);
	
	// sort of a hack, but need to remove the sound loop when changing rooms
	if(rocketLoop){
		[Sound stopLoop:rocketLoop];
		rocketLoop = 0;
	}
}

- (void)update:(Game *)game {
	cpBodyResetForces(body);
	if (directionInput & UP) {
		cpVect thrust = cpvrotate(cpv(0.0, 1.0), cpBodyGetRot(body));
		cpBodyApplyForce(body, cpvmult(thrust, 100000.0), cpvzero);
		
		// add exhaust particles
		for (Sprite *pSprite in exhaustSprites) {
			ParticleCollection *p = [[ParticleCollection alloc] initWithCount:randomInt(1,2) sprite:pSprite physical:NO];
			[p setRelativeToBody:body];
			[p setPositionX:floatRangeMake(-12, 12) Y:floatRangeMake(-37, -35)];
				// [p setVelocityX:floatRangeMake(0,0) Y:floatRangeMake(0,0)];
			[p setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(0,0)];
			[p setVelocityX:floatRangeMake(thrust.x * -300, thrust.x * -300) Y:floatRangeMake(thrust.y * -300, thrust.y * -300)];
			[p setDamping:floatRangeMake(0.97, 0.99)];
			[p setLife:floatRangeMake(0.02, 0.3)];
			[game addItem:p];
		}
		
		if(!rocketLoop){
			rocketLoop = [Sound playLoop:@"Rocket.ogg" volume:1.0 pitch:1.0];
		}
	} else {
		if(rocketLoop){
			[Sound stopLoop:rocketLoop];
			rocketLoop = 0;
		}
	}
	
	float totalTorque = 0;
	if (directionInput & LEFT)
		totalTorque += 100000.0;
	if (directionInput & RIGHT)
		totalTorque -= 100000.0;
	cpBodySetTorque(body, totalTorque);
	
	
}

- (void)draw:(Game *)game {
	cpVect pos = self.position;
	float angle = cpBodyGetAngle(body);

	// discrete steps
	angle /= (M_PI*2);
	angle *= 72.0;
	angle = round(angle);
	angle /= 72.0;
	angle *= (M_PI*2);
	
	[sprite drawAt:pixelCoordsMake(pos.x, pos.y) angle:angle];
	
	if (directionInput & UP) {
		pixelCoords glowLoc = pixelCoordsMake(pos.x + 8 + cpfcos(angle - 90) * 32, pos.y + cpfsin(angle - 90) * 32);
		[[Texture lightmapTexture] addAt:glowLoc radius:120];
	}
}

@end
