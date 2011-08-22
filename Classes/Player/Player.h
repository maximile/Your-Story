#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"
#import "Sprite.h"

@interface Player : PhysicsObject {
	directionMask directionInput;
}

- (void)setInput:(directionMask)direction;
- (void)shoot:(Game *)game;
- (void)drawStatus;

@end
