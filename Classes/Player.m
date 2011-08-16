#import "Player.h"
#import "Texture.h"

@implementation Player

- (id)init {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
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
	// glBegin(GL_LINES);
	// glVertex2f(pos.x - 5, pos.y);
	// glVertex2f(pos.x + 5, pos.y);
	// glVertex2f(pos.x, pos.y - 5);
	// glVertex2f(pos.x, pos.y + 5);
	// glEnd();
	// 
	// pixelRect testTexRect = pixelRectMake(0, 0, 32, 16);
	// pixelRect testRect = pixelRectMake(pos.x - 16, pos.y - 8, 32, 16);
	// [t addRect:testRect texRect:testTexRect];
	// [t drawRects];
	[sprite drawAt:pixelCoordsMake(pos.x, pos.y)];
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
	cpShapeFree(shape1);
	cpShapeFree(shape2);
	cpShapeFree(shape3);
	cpBodyFree(body);
}

- (void)setInput:(directionMask)direction {
	directionInput = direction;
}

@end
