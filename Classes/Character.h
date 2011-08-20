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

#import "Player.h"


struct GroundingContext {
	cpVect normal;
	cpBody *body;
};

@interface Character : Player {
	cpShape *headShape, *feetShape;
	
	Sprite *jumpSprite;
	Sprite *normalSprite;
	NSArray *walkCycle;
	NSDictionary *leftSprites;
	NSDictionary *rightSprites;
	directionMask facing;
	
	bool lastJumpKeyState;
	
	// Body you are standing on and it's normal.
	struct GroundingContext grounding;
	
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

@end
