#import "Pickup.h"
#import "Game.h"

@implementation Pickup

@synthesize used, title;

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Game *game = [Game game];
	cpSpace *space = game.space;
	cpBody *staticBody = cpSpaceGetStaticBody(space);
	shape = cpCircleShapeNew(staticBody, 6.0, cpv(position.x, position.y));
	shape -> data = self;
	cpShapeSetCollisionType(shape, [Pickup class]);
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
	float phase = 2.0*M_PI*self.objectPhase;
	float bob = cpfsin(6.0*game.fixedTime + phase)*0.5 + 0.5;
	float radius = cpflerp(8, 16, bob);
	
	pixelCoords pos = startingPosition;
	pos.y += bob*3.0;
	
	[sprite drawAt:pos];
	[[Texture lightmapTexture] addAt:pos radius:radius];
}

@end
