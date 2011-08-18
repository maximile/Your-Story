#import <Cocoa/Cocoa.h>
#import "GameObject.h"
#import "Types.h"

@interface Item : GameObject {
	mapCoords position;
}

- (id)initWithPosition:(mapCoords)newPosition;

@end
