#import "Item.h"
#import "Sprite.h"

@interface StreetLight : Item {
	Sprite *sprite;
	Texture *lightTexture;
	cpShape *lightArea;
}

@end
