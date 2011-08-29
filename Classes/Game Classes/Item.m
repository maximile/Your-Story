#import "Item.h"

@implementation Item

@synthesize startingPosition;

- (id)initWithPosition:(pixelCoords)newPosition {
	if ([super init] == nil) return nil;
	
	startingPosition = newPosition;
	
	return self;
}

- (void)draw {
	return;
}
- (void)update:(Game *)game {
	return;
}

- (void)addToSpace:(cpSpace *)space {
	return;
}
- (void)removeFromSpace:(cpSpace *)space {
	return;
}


@end
