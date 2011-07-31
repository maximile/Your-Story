//
//  UntitledAppDelegate.m
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GameView.h"

@implementation AppDelegate

@synthesize window, gameView, editorPanel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	game = [[Game alloc] init];
	
	[gameView setGame:game];
	[gameView play];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (IBAction)toggleFullScreen:(id)sender {
    NSDictionary *fullScreenOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFullScreenModeSetting];
	NSView *mainView = [self.window contentView];
	BOOL fullScreen = [mainView isInFullScreenMode];
	
	if (!fullScreen) {
		[mainView enterFullScreenMode:[NSScreen mainScreen] withOptions:fullScreenOptions];
	}
	else {
		[mainView exitFullScreenModeWithOptions:fullScreenOptions];
	}
}

- (IBAction)toggleEditor:(id)sender {
	if (game.mode == GAME_MODE) {
		game.mode = EDITOR_MODE;
		[editorPanel makeKeyAndOrderFront:self];
		[editorPanel setLayer:game.currentRoom.mainLayer];
	}
		
	else if (game.mode == EDITOR_MODE) {
		game.mode = GAME_MODE;
		[editorPanel performClose:self];
	}
}

@end
