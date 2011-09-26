#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "chipmunk.h"
#import "Game.h"

@interface Item : NSObject {
	pixelCoords startingPosition;
	cpFloat objectPhase;
}

@property (readonly) pixelCoords startingPosition;

// Value from 0-1 that is unique to each item usable for animation effects.
@property (readonly) cpFloat objectPhase;

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

- (id)initWithPosition:(pixelCoords)newPosition;
- (void)draw:(Game *)game;
- (void)drawInScreenCoords:(Game *)game;
- (void)update:(Game *)game;

@end
