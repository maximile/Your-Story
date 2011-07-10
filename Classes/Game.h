//
//  Game.h
//  Your Story
//
//  Created by Max Williams on 04/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Player.h"

@interface Game : NSObject {
	Room *currentRoom;
	NSPoint focus;
	
	NSMutableArray *items;
	Player *player;
	
	int upKeyCount, downKeyCount, leftKeyCount, rightKeyCount;
}

- (void)draw;
- (void)update;

- (void)upUp;
- (void)leftUp;
- (void)downUp;
- (void)rightUp;
- (void)upDown;
- (void)downDown;
- (void)leftDown;
- (void)rightDown;

@end
