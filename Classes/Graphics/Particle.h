#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Sprite.h"

typedef struct {
	float life;
	float damping;
	cpVect gravity;
	cpShape *shape;
	cpBody *body;
	BOOL inSpace;
} particle;

typedef struct {
	float min;
	float max;
} floatRange;

static inline floatRange floatRangeMake(float newMin, float newMax) {
	floatRange range;
	range.min = newMin;
	range.max = newMax;
	return range;
}

@interface ParticleCollection : PhysicsObject {
	Sprite *sprite;
	BOOL physical;
	int particleCount;
	particle *particles;
}

- (id)initWithCount:(int)newCount sprite:(Sprite *)newSprite physical:(BOOL)newPhysical;

- (void)setLife:(floatRange)newLife;
- (void)setVelocityX:(floatRange)x Y:(floatRange)y;
- (void)setPositionX:(floatRange)x Y:(floatRange)y;
- (void)setGravityX:(floatRange)x Y:(floatRange)y;
- (void)setDamping:(floatRange)newDamping;

@end
