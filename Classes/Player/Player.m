#import "Player.h"
#import "Texture.h"

@implementation Player

- (void)shoot:(Game *)game {
	return;
}

- (void)setInput:(directionMask)direction jump:(bool)jump shoot:(bool)shoot;
{
	directionInput = direction;
	jumpInput = jump;
	shootInput = shoot;
}

- (void)drawStatus {}

@end
