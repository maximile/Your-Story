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
	// glTranslatef(-player.position.x, -player.position.y, 0.0);
	NSLog(@"%@", currentRoom);
	[currentRoom draw];
	for (GameObject *item in items) {
		[item draw];
	}
}

- (void)update {
	for (GameObject *item in items) {
		[item update];
	}
}

- (void)upDown {upKeyCount++;}
- (void)downDown {downKeyCount++;}
- (void)leftDown {leftKeyCount++;}
- (void)rightDown {rightKeyCount++;}
- (void)upUp {upKeyCount--;}
- (void)downUp {downKeyCount--;}
- (void)leftUp {leftKeyCount--;}
- (void)rightUp {rightKeyCount--;}

@end
