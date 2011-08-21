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

// furthest distance that damage will be taken
#define SHOTGUN_RANGE 100

struct CharacterGroundingContext {
	cpVect normal;
	cpFloat penetration;
	
	cpBody *body;
};

@interface DamageArea : NSObject {}
@end

@interface Character : Player {
	cpShape *headShape, *feetShape;
	
	Sprite *jumpSprite;
	Sprite *normalSprite;
	NSArray *walkCycle;
	NSDictionary *leftSprites;
	NSDictionary *rightSprites;
	directionMask facing;
	
	// number of frames of inlvulnerability (e.g. after hitting an enemy)
	int hurt;
	
	bool lastJumpKeyState;
	
	// Body you are standing on and it's normal.
	struct CharacterGroundingContext grounding;
	
	// Standing on ground that can be walked up.
	bool wellGrounded;
	
	// Amount of jump "boost" time remaining.
	// Gravity is not applied until boost runs out or the jump key is released.
	// This is very mario-esque.
	cpFloat remainingBoost;
	
	// Number of mid-air jumps remaining to be triggered.
	int remainingAirJumps;
	
	// Velocity of the body last stood on
	cpVect groundVelocity;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

- (int)hitJumper:(Jumper *)jumper arbiter:(cpArbiter *)arb;

@end
