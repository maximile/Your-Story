#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"
#import "Sprite.h"

@interface Player : PhysicsObject {
	directionMask directionInput;
	bool jumpInput, shootInput;
}

- (void)setInput:(directionMask)direction jump:(bool)jump shoot:(bool)shoot;
- (void)shoot:(Game *)game;
- (void)drawStatus;
- (id)initWithPosition:(pixelCoords)newPosition state:(NSDictionary *)state;
- (void)updateStateDict:(NSMutableDictionary *)stateDict;


@end
