#import "DoubleJump.h"

@implementation DoubleJump

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(80, 32, 16, 16)];
	title = @"Medallion of Double Jump";
	
	return self;
}

@end
