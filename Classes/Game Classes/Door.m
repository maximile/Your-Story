#import "Door.h"

@implementation Door

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 48, 16, 16)];
	
	return self;
}

- (void)draw:(Game *)game {
	[sprite drawAt:startingPosition];	
}

@end
