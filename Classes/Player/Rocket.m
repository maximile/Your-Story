#import "Rocket.h"

@implementation Rocket

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

	mainShape = cpPolyShapeNew(body, 6, mainVerts, cpvzero);
	coneShape = cpPolyShapeNew(body, 4, coneVerts, cpvzero);
	cpShapeSetFriction(mainShape, 0.7);
	cpShapeSetFriction(coneShape, 0.7);
	
	Texture *texture = [Texture textureNamed:@"MainSprites"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 64, 48, 64)];
	
	return self;
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, mainShape);
	cpSpaceAddShape(space, coneShape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, mainShape);
	cpSpaceRemoveShape(space, coneShape);
}

- (void)update:(Game *)game {
	if (directionInput & UP) {
		cpBodyApplyForce(body, cpvrotate(cpv(0.0, 1000.0), cpBodyGetRot(body)), cpvzero);
	}
	float totalTorque = 0;
	if (directionInput & LEFT)
		totalTorque += 500.0;
	if (directionInput & RIGHT)
		totalTorque -= 500.0;
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
}

@end
