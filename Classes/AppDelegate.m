//
//  UntitledAppDelegate.m
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GameView.h"
#import "Game.h"

@implementation AppDelegate

@synthesize window, gameView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	Game *game = [[Game alloc] init];
	
	[gameView setGame:game];
	[gameView play];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (IBAction)toggleFullScreen:(id)sender {
    NSDictionary *fullScreenOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFullScreenModeSetting] retain];
	NSView *mainView = [self.window contentView];
	BOOL fullScreen = [mainView isInFullScreenMode];
	
	if (!fullScreen) {
		[mainView enterFullScreenMode:[NSScreen mainScreen] withOptions:fullScreenOptions];
	}
	else {
		[mainView exitFullScreenModeWithOptions:fullScreenOptions];
	}
}


@end
