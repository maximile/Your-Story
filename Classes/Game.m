//
//  Game.m
//  Your Story
//
//  Created by Max Williams on 04/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Game.h"


@implementation Game

- (void)draw {
	glTranslatef(focus.x, focus.y, 0.0);
	[currentRoom draw];
}

@end
