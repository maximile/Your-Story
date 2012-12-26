#import "Balloon.h"
#import "RandomTools.h"

@implementation Balloon

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position]==nil) return nil;
	
	body = cpBodyNew(0.1, INFINITY);
	cpBodySetPos(body, cpv(position.x + randomFloat(-4, 4), position.y + randomFloat(-4, 4)));
	cpBodySetUserData(body, self);
	// cpBodySetVelLimit(body, 50);
	
	shape = cpCircleShapeNew(body, 8, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.1);
	cpShapeSetElasticity(shape, 0.7);
	cpShapeSetUserData(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	pixelRect coords;
	switch (randomInt(0,2)) {
		case 0: coords = pixelRectMake(48, 112, 16, 16); break;
		case 1: coords = pixelRectMake(16, 112, 16, 16); break;
		default: coords = pixelRectMake(32, 112, 16, 16); break;
	}
	sprite = [[Sprite alloc] initWithTexture:texture texRect:coords];
	
	return self;
}

- (void)draw:(Game *)game {
	[sprite drawAt:self.pixelPosition];
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
    [super finalize];
}

@end
