//
//  Player.h
//  Your Story
//
//  Created by Max Williams on 10/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"

@interface Player : PhysicsObject {
	cpShape *shape;
	directionMask directionInput;
}

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;
- (void)setInput:(directionMask)direction;

@end
