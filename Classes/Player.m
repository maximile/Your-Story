#import "Player.h"
#import "Texture.h"

@implementation Player

- (id)init {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, 50);
	shape1 = cpCircleShapeNew(body, 8.0, cpv(-8,-1));
	shape2 = cpCircleShapeNew(body, 8.0, cpvzero);
	shape3 = cpCircleShapeNew(body, 8.0, cpv(8,-1));
	cpShapeSetFriction(shape1, 1.5);
	cpShapeSetFriction(shape2, 1.5);
	cpShapeSetFriction(shape3, 1.5);
	
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
	cpSpaceAddShape(space, shape1);
	cpSpaceAddShape(space, shape2);
	cpSpaceAddShape(space, shape3);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, shape1);
	cpSpaceRemoveShape(space, shape2);
	cpSpaceRemoveShape(space, shape3);
}

- (void)update {
	cpBodyResetForces(body);
	if (directionInput & LEFT) {
		// cpBodyApplyForce(body, cpvrotate(cpv(-1000.0, 0.0), cpBodyGetRot(body)), cpvzero);
		cpBodySetTorque(body, 500.0);
	}
	if (directionInput & RIGHT) {
		// cpBodyApplyForce(body, cpvrotate(cpv(1000.0, 0.0), cpBodyGetRot(body)), cpvzero);
		cpBodySetTorque(body, -500.0);
	}
	if (directionInput & UP) {
		cpBodyApplyForce(body, cpvrotate(cpv(0.0, 1000.0), cpBodyGetRot(body)), cpvzero);
	}
	if (directionInput & DOWN) {
		cpBodyApplyForce(body, cpvrotate(cpv(0.0, -1000.0), cpBodyGetRot(body)), cpvzero);
	}
}

- (void)finalize {
	cpShapeFree(shape1);
	cpShapeFree(shape2);
	cpShapeFree(shape3);
	cpBodyFree(body);
}

- (void)setInput:(directionMask)direction {
	directionInput = direction;
}

@end
