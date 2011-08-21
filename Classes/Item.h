#import <Cocoa/Cocoa.h>
#import "GameObject.h"
#import "Types.h"

@interface Item : GameObject {
	pixelCoords startingPosition;
}

- (id)initWithPosition:(pixelCoords)newPosition;

@end
