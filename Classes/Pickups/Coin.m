#import "Coin.h"

@implementation Coin

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 112, 16, 16)];
	title = @"Shiny Coin!";
	
	return self;
}

@end
