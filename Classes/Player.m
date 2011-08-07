#import "Player.h"

@implementation Player

- (id)init {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	shape = cpCircleShapeNew(body, 5.0, cpvzero);
	
	return self;
}

- (void)draw {
	cpVect pos = self.position;
	glBegin(GL_LINES);
	glVertex2f(pos.x - 5, pos.y);
	glVertex2f(pos.x + 5, pos.y);
	glVertex2f(pos.x, pos.y - 5);
	glVertex2f(pos.x, pos.y + 5);
	glEnd();	
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, shape);
}

- (void)update {
	cpBodyResetForces(body);
	if (directionInput & LEFT) {
		cpBodyApplyForce(body, cpv(-1000.0, 0.0), cpvzero);
	}
	if (directionInput & RIGHT) {
		cpBodyApplyForce(body, cpv(1000.0, 0.0), cpvzero);
	}
	if (directionInput & UP) {
		cpBodyApplyForce(body, cpv(0.0, 1000.0), cpvzero);
	}
	if (directionInput & DOWN) {
		cpBodyApplyForce(body, cpv(0.0, -1000.0), cpvzero);
	}
}

- (void)finalize {
	cpShapeFree(shape);
	cpBodyFree(body);
}

- (void)setInput:(directionMask)direction {
	directionInput = direction;
}

@end
