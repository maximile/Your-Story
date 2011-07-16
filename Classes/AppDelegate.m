//
//  UntitledAppDelegate.m
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	for (int i=-5; i<=5; i++) { NSLog(@"%i", abs(i)%3); }
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
