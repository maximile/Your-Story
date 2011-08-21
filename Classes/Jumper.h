#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "Sprite.h"

@interface Jumper : PhysicsObject {
	Sprite *sprite;
	cpShape *shape;
}

- (void)shotFrom:(cpVect)shotLocation;

@end
