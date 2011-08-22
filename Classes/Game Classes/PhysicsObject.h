#import <Cocoa/Cocoa.h>
#import "chipmunk.h"
#import "Item.h"

typedef struct GroundingContext {
	cpVect normal;
	cpFloat penetration;
	
	cpBody *body;
} GroundingContext;

void UpdateGroundingContext(cpBody *body, GroundingContext *context);


@interface PhysicsObject : Item {
	cpBody *body;
}

@property(readonly) cpBody *body;
@property(readonly) pixelCoords pixelPosition;
@property cpVect position;

@end
