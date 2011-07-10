//
//  Player.h
//  Your Story
//
//  Created by Max Williams on 10/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameObject.h"

@interface Player : GameObject {
	NSPoint position;
}

@property NSPoint position;

@end
