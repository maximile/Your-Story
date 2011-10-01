#import "Door.h"

@implementation Door

@synthesize open;

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position] == nil) return nil;
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(32, 48, 16, 16)];
	openSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(64, 64, 16, 16)];
	
	return self;
}

- (void)draw:(Game *)game {
	if (open)
		[openSprite drawAt:startingPosition];	
	else
		[sprite drawAt:startingPosition];	
}

@end
