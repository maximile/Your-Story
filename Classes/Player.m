//
//  Player.m
//  Your Story
//
//  Created by Max Williams on 10/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Player.h"


@implementation Player

@synthesize position;

- (void)draw {
	// glColor3f(0.5, 0.0, 0.0);
	glBegin(GL_LINES);
	glVertex2f(position.x - 5, position.y);
	glVertex2f(position.x + 5, position.y);
	glVertex2f(position.x, position.y - 5);
	glVertex2f(position.x, position.y + 5);
	glEnd();
}

@end
