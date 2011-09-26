#import <Cocoa/Cocoa.h>
#import "Item.h"
#import "chipmunk.h"
#import "Sprite.h"

@interface Pickup : Item {
	cpShape *shape;
	Sprite *sprite;
	BOOL used;
	NSString *title;
}

@property BOOL used;
@property (assign) NSString *title;

@end
