#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"
#import "Sprite.h"

@interface Player : PhysicsObject {
	cpShape *shape1;
	cpShape *shape2;
	cpShape *shape3;
	directionMask directionInput;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;
- (void)setInput:(directionMask)direction;
- (void)shoot:(Game *)game;

@end
