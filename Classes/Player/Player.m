#import "Player.h"
#import "Texture.h"

@implementation Player

- (id)initWithPosition:(pixelCoords)newPosition state:(NSDictionary *)state {
	if ([super initWithPosition:newPosition] == nil) return nil;
	
	return self;
}

- (void)shoot:(Game *)game {
	return;
}

- (void)updateStateDict:(NSMutableDictionary *)stateDict {
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
