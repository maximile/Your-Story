#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "Sprite.h"

@interface Balloon : PhysicsObject {
	Sprite *sprite;
	cpShape *shape;
}

@end
