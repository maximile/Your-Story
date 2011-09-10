#import "Pickup.h"
#import "Game.h"

@implementation Pickup

@synthesize used;

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Game *game = [Game game];
	cpSpace *space = game.space;
	cpBody *staticBody = cpSpaceGetStaticBody(space);
	shape = cpCircleShapeNew(staticBody, 6.0, cpv(position.x, position.y));
	shape -> data = self;
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetSensor(shape, cpTrue);
	
	return self;
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveShape(space, shape);
}

- (void)finalize {
	cpShapeFree(shape);
	[super finalize];
}

- (void)draw:(Game *)game {
	[sprite drawAt:startingPosition];
	
	float phase = 2.0*M_PI*self.objectPhase;
	float radius = cpflerp(8, 16, cpfsin(6.0*game.fixedTime + phase)*0.5 + 0.5);
	[[Texture lightmapTexture] addAt:startingPosition radius:radius];
}

@end
