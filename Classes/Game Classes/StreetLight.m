#import "StreetLight.h"

@implementation StreetLight
- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 51, 32, 13)];

	lightTexture = [[Texture lightmapTextures] objectAtIndex:1];
	
	cpVect verts[3];
	verts[0] = cpvzero;
	verts[1] = cpv(40, -80);
	verts[2] = cpv(-40, -80);
	cpVect lightPos = cpv(startingPosition.x + 14, startingPosition.y);
	lightArea = cpPolyShapeNew(cpSpaceGetStaticBody([Game game].space), 3, verts, lightPos);
	cpShapeSetSensor(lightArea, cpTrue);
	cpShapeSetCollisionType(lightArea, [self class]);
	
	return self;
}

- (void)draw:(Game *)game {
	pixelCoords spritePos = pixelCoordsMake(startingPosition.x + 12, startingPosition.y - 2);
	[sprite drawAt:spritePos];
	
	pixelCoords lightPos = pixelCoordsMake(startingPosition.x + 14, startingPosition.y - 51);
	[lightTexture addAt:lightPos radius:64];
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddShape(space, lightArea);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveShape(space, lightArea);
}

@end
