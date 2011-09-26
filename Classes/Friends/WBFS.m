#import "WBFS.h"

@implementation WBFS

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 80, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(16, 80, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 80, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 80, 16, 16)],
	nil];
	
	frameTimes = calloc(4, sizeof(float));
	frameTimes[0] = 0.3;
	frameTimes[1] = 0.3;
	frameTimes[2] = 0.3;
	frameTimes[3] = 0.3;
	
	dialogue = [NSArray arrayWithObjects:
		@"Work! Beat! Fierce! Sound!",
		@"Oh hi, do you want to go in there?",
		@"You'll want to find a torch first.",
		@"I think there's one left...",
		@"...in that warehouse to the West.",
		@"Work! Beat!",
		@"Fierce! Sound!",
	nil];
	
	return self;
}

@end
