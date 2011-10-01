#import "Spawn.h"
#import "Sprite.h"

@interface Door : Spawn {
	Sprite *sprite;
	Sprite *openSprite;
	BOOL open;
}

@property BOOL open;

@end
