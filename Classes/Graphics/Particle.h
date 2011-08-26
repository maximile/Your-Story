#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Sprite.h"

@interface Particle : PhysicsObject {
	Sprite *sprite;
	BOOL physical;
	cpShape *shape;
	float life;
	
	float damping;
	cpVect gravity;
}

@property (readonly) BOOL physical;
@property float life;
@property float damping;
@property cpVect gravity;

- (id)initAt:(pixelCoords)position sprite:(Sprite *)newSprite physical:(BOOL)newPhysical;

@end
