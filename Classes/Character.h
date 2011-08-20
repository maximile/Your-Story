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
	
	bool lastJumpState;
	struct GroundingContext grounding;
	cpFloat remainingBoost;
	int remainingAirJumps;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

@end
