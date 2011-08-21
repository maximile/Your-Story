#import "Item.h"

@implementation Item

- (id)initWithPosition:(pixelCoords)newPosition {
	if ([super init] == nil) return nil;
	
	startingPosition = newPosition;
	NSLog(@"%i, %i", startingPosition.x, startingPosition.y);
	
	return self;
}

@end
