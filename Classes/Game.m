//
//  Game.m
//  Your Story
//
//  Created by Max Williams on 04/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Game.h"
#import "GameObject.h"
#import "Constants.h"

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
	// camera target
	focus = player.position;
	
	if (currentRoom.mainLayer.size.height * TILE_SIZE <= CANVAS_HEIGHT) {
		// room is shorter than the screen, center it vertically
		focus.y = CANVAS_HEIGHT / 2;
	}
	else {
		// clamp focus to height of room
		focus.y = player.position.y;
		if (focus.y < CANVAS_HEIGHT / 2) {
			focus.y = CANVAS_HEIGHT / 2;
		}
		else if (focus.y > (currentRoom.size.height * TILE_SIZE) - CANVAS_HEIGHT / 2) {
			focus.y = (currentRoom.size.height * TILE_SIZE) - CANVAS_HEIGHT / 2;
		}
	}
	
	if (currentRoom.mainLayer.size.width * TILE_SIZE <= CANVAS_WIDTH) {
		// room is thinner than the screen, center it horizontally
		focus.x = CANVAS_WIDTH / 2;
	}
	else {
		// clamp focus to width of room
		focus.x = player.position.x;
		if (focus.x < CANVAS_WIDTH / 2) {
			focus.x = CANVAS_WIDTH / 2;
		}
		else if (focus.x > (currentRoom.size.width * TILE_SIZE) - CANVAS_WIDTH / 2) {
			focus.x = (currentRoom.size.width * TILE_SIZE) - CANVAS_WIDTH / 2;
		}
	}
	
	// draw layers. first get screen bounds in map coords
	int left = (focus.x - CANVAS_WIDTH / 2) / TILE_SIZE;
	int right = (focus.x + CANVAS_WIDTH / 2) / TILE_SIZE + 1;
	int top = (focus.y + CANVAS_HEIGHT / 2) / TILE_SIZE + 1;
	int bottom = (focus.y - CANVAS_HEIGHT / 2) / TILE_SIZE;
	
	// bg elements
	glPushMatrix();
	float bgParallax = currentRoom.bgLayer.parallax;
	NSPoint parallaxFocus = NSMakePoint(focus.x * bgParallax, focus.y * bgParallax);
	
	int pLeft = (parallaxFocus.x - CANVAS_WIDTH / 2) / TILE_SIZE - 1;
	int pRight = (parallaxFocus.x + CANVAS_WIDTH / 2) / TILE_SIZE + 1;
	int pTop = (parallaxFocus.y + CANVAS_HEIGHT / 2) / TILE_SIZE + 1;
	int pBottom = (parallaxFocus.y - CANVAS_HEIGHT / 2) / TILE_SIZE - 1;
		
	// glTranslatef(-focus.x, -focus.y, 0.0);
	// glTranslatef(parallaxOffset.width, parallaxOffset.height, 0.0);
	// glTranslatef(-parallaxFocus.x, -parallaxFocus.y, 0.0);
	glTranslatef(-(parallaxFocus.x - CANVAS_WIDTH / 2), -(parallaxFocus.y - CANVAS_HEIGHT / 2), 0.0);
	
	[currentRoom.bgLayer drawFrom:tileCoordsMake(pLeft, pBottom) to:tileCoordsMake(pRight, pTop)];
	glPopMatrix();
	
	// midground elements
	glPushMatrix();
	glTranslatef(-(focus.x - CANVAS_WIDTH / 2), -(focus.y - CANVAS_HEIGHT / 2), 0.0);
	[currentRoom.mainLayer drawFrom:tileCoordsMake(left, bottom) to:tileCoordsMake(right, top)];
	
	[currentRoom.mainLayer drawCollision];
	
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
