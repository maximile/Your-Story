//
//  UntitledAppDelegate.h
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainView.h"
#import "Game.h"

@interface AppDelegate : NSObject {
    NSWindow *window;
	GameView *gameView;
	Game *game;
	NSString *roomPath;
}

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)toggleEditor:(id)sender;
- (IBAction)saveMap:(id)sender;
- (IBAction)openMap:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GameView *gameView;

@end
