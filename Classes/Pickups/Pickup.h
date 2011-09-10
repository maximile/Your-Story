#import <Cocoa/Cocoa.h>
#import "Item.h"
#import "chipmunk.h"
#import "Sprite.h"

@interface Pickup : Item {
	cpShape *shape;
	Sprite *sprite;
	BOOL used;
}

@property BOOL used;

@end
