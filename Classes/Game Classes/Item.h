#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "chipmunk.h"

@interface Item : NSObject {
	pixelCoords startingPosition;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

- (id)initWithPosition:(pixelCoords)newPosition;
- (void)draw;
- (void)update;

@end
