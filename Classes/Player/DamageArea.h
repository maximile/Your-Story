#import <Cocoa/Cocoa.h>
#import "Item.h"

// furthest distance that damage will be taken
#define SHOTGUN_RANGE 100

@interface DamageArea : Item {
	cpVect pos;
	cpShape *shape;
}

- (id)initWithPosition:(cpVect)newPos direction:(directionMask)direction;

@end
