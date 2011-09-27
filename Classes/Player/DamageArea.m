#import "Game+Items.h"
#import "DamageArea.h"
#import "PhysicsObject.h"
#import "Sprite.h"

@implementation DamageRay

@synthesize layers, group;

-(id)initWithPosition:(cpVect)newPos velocity:(cpVect)newVel distance:(cpFloat)newDistance damage:(float)newDamage;
{
	if([super init] == nil) return nil;
	
	startPos = newPos;
	velocity = newVel;
	
	layers = CP_ALL_LAYERS;
	group = CP_NO_GROUP;
	
	clampTime = newDistance/cpvlength(newVel);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(3, 51, 11, 10)];
	
	damage = newDamage;
	
	return self;
}

- (void)update:(Game *)game
{
	double time = game.fixedTime;
	if(startTime == 0.0) startTime = time;
	
	cpFloat delta = time - startTime;
	if(delta < clampTime){
		
		cpVect a = cpvadd(startPos, cpvmult(velocity, delta));
		cpVect b = cpvadd(startPos, cpvmult(velocity, delta + FIXED_DT*2.0));
		
		cpShape *shape = cpSpaceSegmentQueryFirst(game.space, a, b, layers, group, NULL);
		if(shape){
			if([(id)shape->data isKindOfClass:[PhysicsObject class]])
				[(PhysicsObject *)shape->data shotFrom:a damage:damage];
			
			[game removeItem:self];
		}
	} else {
		[game removeItem:self];
	}
}

-(void)draw:(Game *)game;
{
	cpVect pos = cpvadd(startPos, cpvmult(velocity, game.fixedTime - startTime));
	[sprite drawAt:pixelCoordsMake(pos.x, pos.y) angle:0.0];
}

@end

//@implementation DamageArea
//
//- (id)initWithPosition:(cpVect)newPos direction:(directionMask)direction {
//	if ([super init] == nil) return nil;
//	
//	pos = newPos;
//	
//	// create sensor shape
//	cpVect verts[3];
//	float rangeEnd = SHOTGUN_RANGE;
//	if (direction & LEFT) {
//		verts[0] = cpvzero;
//		verts[1] = cpv(-rangeEnd, -20);
//		verts[2] = cpv(-rangeEnd, 20);
//	}
//	else {
//		verts[0] = cpvzero;
//		verts[1] = cpv(rangeEnd, 20);
//		verts[2] = cpv(rangeEnd, -20);
//	}
//	
//	shape = cpPolyShapeNew(cpSpaceGetStaticBody([Game game].space), 3, verts, pos);
//	cpShapeSetSensor(shape, cpTrue);
//	cpShapeSetCollisionType(shape, [self class]);
//	
//	return self;
//}
//
//- (void)addToSpace:(cpSpace *)space {
//	cpSpaceAddShape(space, shape);
//}
//
//- (void)removeFromSpace:(cpSpace *)space {
//	cpSpaceRemoveShape(space, shape);
//}
//
//- (void)update:(Game *)game {
//	// remove it asap; we only want it around for one step
//	[game removeItem:self];
//}
//
//- (void)finalize {
//	cpShapeFree(shape);
//	[super finalize];
//}
//
//@end
