#import "Item.h"

@implementation Item

@synthesize startingPosition;

- (id)initWithPosition:(pixelCoords)newPosition {
	if ([super init] == nil) return nil;
	
	startingPosition = newPosition;
	
	return self;
}

- (void)draw:(Game *)game {}
- (void)drawInScreenCoords:(Game *)game {}
- (void)update:(Game *)game {}

- (void)addToSpace:(cpSpace *)space {}
- (void)removeFromSpace:(cpSpace *)space {}

-(float)objectPhase {
	return (float)((int)self&255)/255.0;
}

@end
