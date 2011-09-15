#import "Shotgun.h"

@implementation Shotgun

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;

	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(64, 32, 16, 16)];
	
	return self;
}

@end
