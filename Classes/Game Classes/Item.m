#import "Item.h"

@implementation Item

@synthesize startingPosition, objectPhase;

- (id)initWithPosition:(pixelCoords)newPosition {
	if ([super init] == nil) return nil;
	
	startingPosition = newPosition;
	objectPhase = (cpFloat)rand()/(cpFloat)RAND_MAX;
	
	return self;
}

- (void)draw:(Game *)game {}
- (void)drawInScreenCoords:(Game *)game {}
- (void)update:(Game *)game {}

- (void)addToSpace:(cpSpace *)space {}
- (void)removeFromSpace:(cpSpace *)space {}

@end
