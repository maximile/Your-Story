#import "Parasprite.h"
#import "RandomTools.h"
#import "Player.h"

@implementation Parasprite

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position]==nil) return nil;
	
	body = cpBodyNew(2, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	cpBodySetVelLimit(body, 50);
	
	shape = cpCircleShapeNew(body, 4, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.2);
	cpShapeSetGroup(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	pixelRect bodyCoords;
	NSLog(@"%i", randomInt(0,3));
	switch (randomInt(0,3)) {
		case 0: bodyCoords = pixelRectMake(97, 1, 9, 9); break;
		case 1: bodyCoords = pixelRectMake(108, 1, 9, 9); break;
		case 2: bodyCoords = pixelRectMake(97, 12, 9, 9); break;
		default: bodyCoords = pixelRectMake(108, 12, 9, 9); break;
	}
	bodySprite = [[Sprite alloc] initWithTexture:texture texRect:bodyCoords];
	eyesSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 23, 9, 5)];
	feetSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(110, 25, 5, 2)];
	wingsOneSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 42, 11, 10)];
	wingsTwoSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 30, 23, 10)];
	
	return self;
}

- (void)draw:(Game *)game {	
	pixelCoords pixelPos = self.pixelPosition;
	
	// draw wings
	float flapRate = 24.0;
	if (self.body->f.y > 2000.0) {
		flapRate = 64.0;
	}
	pixelCoords wingPos = pixelCoordsMake(pixelPos.x, pixelPos.y + 6);
	Sprite *wingsSprite;
	if (cpfsin(flapRate*(game.fixedTime + self.objectPhase)) > 0)
		wingsSprite = wingsOneSprite;
	else
		wingsSprite = wingsTwoSprite;
	[wingsSprite drawAt:wingPos];
	
	[bodySprite drawAt:pixelPos];
	[eyesSprite drawAt:pixelPos];
	[feetSprite drawAt:pixelCoordsMake(pixelPos.x, pixelPos.y -4)];
}

- (void)update:(Game *)game {
	// set target - chase player if near enough, else return home
	cpVect target = cpv(startingPosition.x, startingPosition.y);
	Player *player = game.player;
	if (player && cpvnear(player.position, self.position, 100)) {
		target = player.position;
	}
	
	// apply force towards target, with strenth varying periodically
	float phase = 2.0*M_PI*self.objectPhase;
	float enthusiasm = cpfsin(2.0*game.fixedTime + phase) * 0.5 + 0.5;
	cpVect gravityForce = cpv(0, 2000);
	cpVect targetForce = cpvsub(target, self.position);
	if (targetForce.x == 0 && targetForce.y == 0) targetForce = cpv(0,1);
	targetForce = cpvnormalize(targetForce);
	targetForce = cpvmult(targetForce, enthusiasm * 500);
	cpBodySetForce(body, cpvadd(targetForce, gravityForce));
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, shape);
}

- (void)finalize {
	cpShapeFree(shape);
	cpBodyFree(body);
}

@end
