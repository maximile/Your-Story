#import <Cocoa/Cocoa.h>
#import "Item.h"

// furthest distance that damage will be taken
#define SHOTGUN_RANGE 100

@interface Bullet : Item {
	cpVect startPos;
	cpVect velocity;
	
	double startTime;
	double clampTime;
	
	cpLayers layers;
	cpGroup group;
	
	Sprite *sprite;
	float damage;
}

@property(assign) cpLayers layers;
@property(assign) cpGroup group;
@property(assign) double startTime;

-(id)initWithPosition:(cpVect)newPos velocity:(cpVect)newVel distance:(cpFloat)newDistance damage:(float)damage;

@end



@interface PistolBullet : Bullet
@end
