#import "Purple.h"

@implementation Purple

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 64, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(16, 64, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 64, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 64, 16, 16)],
	nil];
	
	frameTimes = calloc(4, sizeof(float));
	frameTimes[0] = 0.6;
	frameTimes[1] = 0.2;
	frameTimes[2] = 0.2;
	frameTimes[3] = 0.4;
	
	dialogue = [NSArray arrayWithObjects:
		@"What am I doing? Just hitting this grass.",
		@"I’ll keep hitting it until it's flat.",
	nil];
	
	return self;
}

@end
