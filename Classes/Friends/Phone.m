#import "Phone.h"

@implementation Phone

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(16, 96, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 96, 16, 16)],
	nil];
	
	frameTimes = calloc(2, sizeof(float));
	frameTimes[0] = 0.1;
	frameTimes[1] = 0.1;
	
	dialogue = [NSArray arrayWithObjects:
		@"Hello peasant!",
		@"You have been selected for promotion!",
		@"Please step into the promotion elevator.",
	nil];
	
	return self;
}

@end
