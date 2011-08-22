#import "Game+Items.h"
#import "DamageArea.h"

@implementation DamageArea

- (id)initWithPosition:(cpVect)newPos direction:(directionMask)direction {
	if ([super init] == nil) return nil;
	
	pos = newPos;
	
	// create sensor shape
	cpVect verts[3];
	float rangeEnd = SHOTGUN_RANGE;
	if (direction & LEFT) {
		verts[0] = cpvzero;
		verts[1] = cpv(-rangeEnd, -20);
		verts[2] = cpv(-rangeEnd, 20);
	}
	else {
		verts[0] = cpvzero;
		verts[1] = cpv(rangeEnd, 20);
		verts[2] = cpv(rangeEnd, -20);
	}
	
	shape = cpPolyShapeNew(cpSpaceGetStaticBody([Game game].space), 3, verts, pos);
	cpShapeSetSensor(shape, cpTrue);
	cpShapeSetCollisionType(shape, [self class]);
	
	return self;
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveShape(space, shape);
}

- (void)update:(Game *)game {
	// remove it asap; we only want it around for one step
	[game removeItem:self];
}

- (void)finalize {
	cpShapeFree(shape);
	[super finalize];
}

@end
