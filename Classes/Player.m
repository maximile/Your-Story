//
//  Player.m
//  Your Story
//
//  Created by Max Williams on 10/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Player.h"


@implementation Player

- (void)draw {
	// glColor3f(0.5, 0.0, 0.0);
	// glBegin(GL_LINES);
	// glVertex2f(position.x - 5, position.y);
	// glVertex2f(position.x + 5, position.y);
	// glVertex2f(position.x, position.y - 5);
	// glVertex2f(position.x, position.y + 5);
	// glEnd();
	glBegin(GL_LINES);
	glVertex2f(cpBodyGetPos(body).x - 5, cpBodyGetPos(body).y);
	glVertex2f(cpBodyGetPos(body).x + 5, cpBodyGetPos(body).y);
	glVertex2f(cpBodyGetPos(body).x, cpBodyGetPos(body).y - 5);
	glVertex2f(cpBodyGetPos(body).x, cpBodyGetPos(body).y + 5);
	glEnd();
}

- (NSPoint)getPosition {
	return NSMakePoint(cpBodyGetPos(body).x, cpBodyGetPos(body).y);
}

- (void)addToSpace:(cpSpace *)space {
	body = cpBodyNew(5, INFINITY);
	shape = cpCircleShapeNew(body, 5.0, cpvzero);
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
	cpBodySetPos(body, cpv(120,120));
}

- (void)removeFromSpace:(cpSpace *)space {
	body = cpBodyNew(5, INFINITY);
	shape = cpCircleShapeNew(body, 5.0, cpvzero);
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
}

- (void)updateForce:(cpVect)force {
	NSLog(@"HERE");
	cpBodyResetForces(body);
	cpBodyApplyForce(body, force, cpvzero);
}


@end
