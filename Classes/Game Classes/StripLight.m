#import "StripLight.h"

@implementation StripLight
- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(49, 49, 28, 5)];

	// lightTexture = [Texture textureNamed:@"light-spread.psd"];
	lightTexture = [[Texture lightmapTextures] objectAtIndex:1];
	
	
	return self;
}

- (void)draw:(Game *)game {
	pixelCoords spritePos = pixelCoordsMake(startingPosition.x, startingPosition.y + 5);
	[sprite drawAt:spritePos];
	
	pixelCoords lightPos = pixelCoordsMake(startingPosition.x, startingPosition.y - 47);
	[lightTexture addAt:lightPos radius:64];
}

@end
