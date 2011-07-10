//
//  Game.m
//  Your Story
//
//  Created by Max Williams on 04/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Game.h"
#import "GameObject.h"

@implementation Game

- (id)init {
	if ([super init] == nil) {
		return nil;
	}
	items = [[NSMutableArray alloc] initWithCapacity:0];
	player = [[Player alloc] init];
	[items addObject:player];
	player.position = NSMakePoint(50, 50);
	
	upKeyCount = 0;
	downKeyCount = 0;
	leftKeyCount = 0;
	rightKeyCount = 0;
	
	currentRoom = [[Room alloc] initWithName:@"Test"];
	
	return self;
}

- (void)draw {
	glPushMatrix();
	glTranslatef(-player.position.x, -player.position.y, 0.0);
	[currentRoom draw];
	for (GameObject *item in items) {
		[item draw];
	}
	glPopMatrix();
}

- (void)update {
	if (upKeyCount > 0) player.position = NSMakePoint(player.position.x, player.position.y + 1);
	if (downKeyCount > 0) player.position = NSMakePoint(player.position.x, player.position.y - 1);
	if (leftKeyCount > 0) player.position = NSMakePoint(player.position.x - 1, player.position.y);
	if (rightKeyCount > 0) player.position = NSMakePoint(player.position.x + 1, player.position.y);
	for (GameObject *item in items) {
		[item update];
	}
}

- (void)upDown {upKeyCount=1;}
- (void)downDown {downKeyCount=1;}
- (void)leftDown {leftKeyCount=1;}
- (void)rightDown {rightKeyCount=1;}
- (void)upUp {upKeyCount=0;}
- (void)downUp {downKeyCount=0;}
- (void)leftUp {leftKeyCount=0;}
- (void)rightUp {rightKeyCount=0;}

@end
