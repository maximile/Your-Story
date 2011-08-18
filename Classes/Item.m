#import "Item.h"

@implementation Item

- (id)initWithPosition:(mapCoords)newPosition {
	if ([super init] == nil) return nil;
	
	position = newPosition;
	NSLog(@"%i, %i", position.x, position.y);
	
	return self;
}

@end
