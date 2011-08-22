//
//  Jumper.m
//  Your Story
//
//  Created by Max Williams on 21/08/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Jumper.h"
#import "Player.h"

#define JUMP_HEIGHT (TILE_SIZE*2)
#define JUMP_INTERVAL 1.5

@implementation Jumper

- (id)initWithPosition:(pixelCoords)position {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	
	shape = cpCircleShapeNew(body, 8.0, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.7);
	cpShapeSetGroup(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 16, 16, 16)];
	
	lastJumpTime = -INFINITY;
	
	return self;
}

static inline cpFloat
cpfsign(cpFloat f)
{
	return (f > 0) - (f < 0);
}

- (void)update:(Game *)game {
	UpdateGroundingContext(body, &grounding);
	
	Player *player = game.player;
	cpVect playerPos = player.position;
	cpVect pos = cpBodyGetPos(body);
	
	double elapsed = game.fixedTime - lastJumpTime;
	
	if(grounding.body && elapsed > JUMP_INTERVAL && cpvnear(playerPos, pos, 96)){
		cpShape *hit = cpSpaceSegmentQueryFirst(game.space, pos, playerPos, CP_ALL_LAYERS, self, NULL);
		if(hit->body == player.body){
			cpFloat jump_v = cpfsqrt(2.0*JUMP_HEIGHT*GRAVITY);
			body->v = cpvadd(grounding.body->v, cpv(cpfsign(playerPos.x - pos.x)*jump_v/3.0, jump_v));
			
			lastJumpTime = game.fixedTime;
		}
	}
}


// TODO duplicated code
-(pixelCoords)pixelPosition
{
	// Correct the drawn position for overlap with the grounding object.
	cpVect pos = cpvadd(cpBodyGetPos(body), cpvmult(grounding.normal, grounding.penetration - COLLISION_SLOP));
	return pixelCoordsMake(round(pos.x), round(pos.y));
}

- (void)draw {
	[sprite drawAt:self.pixelPosition];
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

- (void)shotFrom:(cpVect)shotLocation {
	cpVect pos = cpBodyGetPos(body);
	float strength = 100 - cpvdist(pos, shotLocation);
	cpVect effect = cpvnormalize(cpv(1.0, 0.6));
	if (shotLocation.x > pos.x) {
		effect.x *= -1;
	}
	effect = cpvmult(effect, strength * 5);
	cpBodyApplyImpulse(body, effect, cpvzero);
}

@end
