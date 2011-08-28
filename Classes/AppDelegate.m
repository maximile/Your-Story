#import "AppDelegate.h"
#import "MainView.h"

@implementation AppDelegate

@synthesize window, gameView;

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
		[gameView.window makeFirstResponder:gameView];
	}
	else {
		[mainView exitFullScreenModeWithOptions:fullScreenOptions];
	}
}

- (IBAction)toggleEditor:(id)sender {
	if (game.mode == GAME_MODE) {
		game.mode = EDITOR_MODE;
	}
		
	else if (game.mode == EDITOR_MODE) {
		game.mode = GAME_MODE;
	}
}

- (IBAction)openMap:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObject:@"ysroom"] modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	roomPath = panel.filenames.lastObject;
	if (roomPath.length) {
		[game setCurrentRoomFromPath:roomPath];
	}
}

- (IBAction)saveMap:(id)sender {
	if (!roomPath.length) {
		NSBeep();
		return;
	}
	[game writeCurrentRoomToPath:roomPath];
}


@end
