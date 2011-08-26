//
//  Player.h
//  Your Story
//
//  Created by Scott Lembcke on 10/17/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"
#import "Sprite.h"
#import "Jumper.h"
#import "Player.h"
#import "Health.h"


@interface Character : Player {
	cpShape *headShape, *feetShape;
	
	Sprite *jumpSprite;
	Sprite *normalSprite;
	Sprite *fullHealth;
	Sprite *emptyHealth;
	NSArray *walkCycle;
	NSDictionary *leftSprites;
	NSDictionary *rightSprites;
	NSArray *shotgunParticleSprites;
	Sprite *smokeParticleSprite;
	directionMask facing;
	
	// number of frames of inlvulnerability (e.g. after hitting an enemy)
	int hurt;
	int reload;
	
	int health;
	
	bool lastJumpKeyState;
	
	// Body you are standing on and it's normal.
	GroundingContext grounding;
	
	// Standing on ground that can be walked up.
	bool wellGrounded;
	
	// Amount of jump "boost" time remaining.
	// Gravity is not applied until boost runs out or the jump key is released.
	// This is very mario-esque.
	cpFloat remainingBoost;
	
	// Number of mid-air jumps remaining to be triggered.
	int remainingAirJumps;
	
	// remaining time you're able to jump after walking off a ledge
	float remainingJumpLeniency;
	
	// Velocity of the body last stood on
	cpVect groundVelocity;
	
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

- (int)hitJumper:(Jumper *)jumper arbiter:(cpArbiter *)arb;
- (int)hitHealth:(Health *)health arbiter:(cpArbiter *)arb;

- (void)addHealth:(int)healthDiff;

@end
