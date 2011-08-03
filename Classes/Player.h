//
//  Player.h
//  Your Story
//
//  Created by Max Williams on 10/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameObject.h"
#import "chipmunk.h"

@interface Player : GameObject {
	// NSPoint position;
	
	cpBody *body;
	cpShape *shape;
}

- (NSPoint)getPosition;

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;
- (void)updateForce:(cpVect)force;


@end
