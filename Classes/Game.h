//
//  Game.h
//  Your Story
//
//  Created by Max Williams on 04/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Room.h"

@interface Game : NSObject {
	Room *currentRoom;
	NSPoint focus;
}

@end
