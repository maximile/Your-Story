#import "Operator.h"

@implementation Operator

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprites = [NSArray arrayWithObjects:
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 96, 16, 16)],
		[[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 96, 16, 16)],
	nil];
	
	frameTimes = calloc(2, sizeof(float));
	frameTimes[0] = 0.25;
	frameTimes[1] = 0.25;
	
	dialogue = [NSArray arrayWithObjects:
		@"Your phone is ringing.",
		@"Why are we the last ones left?",
		@"Everyone else has been promoted.",
	nil];
	
	return self;
}

//- (void)displayMessage:(Game *)game {
//	[game.stateDict setValue:[NSNumber numberWithBool:YES] forKey:@"SpokenToOperator"];
//}

@end
