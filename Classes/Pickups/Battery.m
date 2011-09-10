#import "Battery.h"

@implementation Battery

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(48, 32, 16, 16)];
		
	return self;
}

@end
