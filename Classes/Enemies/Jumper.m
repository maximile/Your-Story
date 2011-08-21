//
//  Jumper.m
//  Your Story
//
//  Created by Max Williams on 21/08/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Jumper.h"


@implementation Jumper

- (id)initWithPosition:(pixelCoords)position {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(5, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	
	shape = cpCircleShapeNew(body, 8.0, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	sprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(0, 16, 16, 16)];
	return self;
}

- (void)draw {
	cpVect pos = cpBodyGetPos(body);
	[sprite drawAt:pixelCoordsMake(pos.x, pos.y)];
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
	cpVect effect = cpvnormalize(cpv(1.0, 0.2));
	if (shotLocation.x > pos.x) {
		effect.x *= -1;
	}
	effect = cpvmult(effect, strength);
	cpBodyApplyImpulse(body, effect, cpvzero);
}

@end
