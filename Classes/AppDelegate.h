//
//  UntitledAppDelegate.h
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"

@interface AppDelegate : NSObject {
    NSWindow *window;
	GameView *gameView;
}

- (IBAction)toggleFullScreen:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GameView *gameView;

@end
