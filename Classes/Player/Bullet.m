#import "Game+Items.h"
#import "Bullet.h"
#import "PhysicsObject.h"
#import "Sprite.h"
#import "Particle.h"
#import "Sound.h"

@implementation Bullet

@synthesize layers, group, startTime;

-(id)initWithPosition:(cpVect)newPos velocity:(cpVect)newVel distance:(cpFloat)newDistance damage:(float)newDamage;
{
	if([super init] == nil) return nil;
	
	startPos = newPos;
	velocity = newVel;
	
	layers = CP_ALL_LAYERS;
	group = CP_NO_GROUP;
	
	clampTime = newDistance/cpvlength(newVel);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(10, 4, 4, 2)];
	
	damage = newDamage;
	
	return self;
}

-(void)fizzleOut:(Game *)game point:(cpVect)point
{
	[game removeItem:self];
}

-(void)hitSomething:(Game *)game point:(cpVect)point normal:(cpVect)normal
{
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	Sprite *particle = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(10, 4, 1, 1)];
	
	ParticleCollection *ricochet = [[ParticleCollection alloc] initWithCount:5 sprite:particle physical:NO];
	[ricochet setPositionX:floatRangeMake(point.x, point.x) Y:floatRangeMake(point.y, point.y)];
	if(normal.x < 0.0){
		[ricochet setVelocityX:floatRangeMake(-200.0, -100.0) Y:floatRangeMake(-30, 30)];
	} else {
		[ricochet setVelocityX:floatRangeMake(100.0, 200.0) Y:floatRangeMake(-30, 30)];
	}
	[ricochet setLife:floatRangeMake(0.1, 0.2)];
	[game addItem:ricochet];
	
	[game removeItem:self];
}

- (void)update:(Game *)game
{
	double time = game.fixedTime;
	if(startTime == 0.0) startTime = time;
	
	cpFloat delta = time - startTime;
	if(delta < clampTime){
		cpVect a = cpvadd(startPos, cpvmult(velocity, delta));
		cpVect b = cpvadd(startPos, cpvmult(velocity, cpfmin(clampTime, delta + FIXED_DT*2.0)));
		
		cpSegmentQueryInfo info = {};
		cpShape *shape = cpSpaceSegmentQueryFirst(game.space, a, b, layers, group, &info);
		if(shape){
			cpVect point = cpSegmentQueryHitPoint(a, b, info);
			
			if([(id)shape->data isKindOfClass:[PhysicsObject class]])
				[(PhysicsObject *)shape->data shotFrom:point damage:damage];
			
			[self hitSomething:game point:point normal:info.n];
		}
	} else {
		[self fizzleOut:game point:cpvadd(startPos, cpvmult(velocity, clampTime))];
	}
}

-(void)draw:(Game *)game;
{
	cpVect pos = cpvadd(startPos, cpvmult(velocity, cpfmin(clampTime, game.fixedTime - startTime)));
	[sprite drawAt:pixelCoordsMake(pos.x, pos.y) angle:0.0];
}

@end



@implementation PistolBullet

-(void)fizzleOut:(Game *)game point:(cpVect)point
{
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	Sprite *particle = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(10, 4, 1, 1)];
	
	ParticleCollection *poof = [[ParticleCollection alloc] initWithCount:15 sprite:particle physical:NO];
	[poof setPositionX:floatRangeMake(point.x, point.x) Y:floatRangeMake(point.y, point.y)];
	[poof setVelocityX:floatRangeMake(-100.0, 100.0) Y:floatRangeMake(-100, 100)];
	[poof setLife:floatRangeMake(0.05, 0.1)];
	[game addItem:poof];
	
	[Sound playSound:@"BulletHit.ogg" volume:0.5 pitch:0.5];
	[super fizzleOut:game point:point];
}

-(void)hitSomething:(Game *)game point:(cpVect)point normal:(cpVect)normal
{
	[Sound playSound:@"BulletHit.ogg" volume:0.5 pitch:1.0];
	[super hitSomething:game point:point normal:normal];
}

@end