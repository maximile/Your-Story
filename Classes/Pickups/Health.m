#import "Health.h"
#import "Game.h"

@implementation Health

@synthesize used;

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(3, 51, 11, 10)];
	
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

- (void)draw {
	[sprite drawAt:startingPosition];
	[[Texture lightmapTexture] addAt:startingPosition radius:12];
}

@end
