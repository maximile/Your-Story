#import "Torch.h"

@implementation Torch

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(112, 48, 16, 16)];
	title = @"Torch";
	
	return self;
}

@end
