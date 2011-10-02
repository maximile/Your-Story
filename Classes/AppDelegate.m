#import "AppDelegate.h"
#import "MainView.h"

#import <OpenAL/alc.h>
#import "Music.h"

@implementation AppDelegate

@synthesize window, gameView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	ALCdevice *device = alcOpenDevice(NULL);
	ALCcontext *context = alcCreateContext(device, NULL);
	alcMakeContextCurrent(context);
	NSLog(@"OpenAL context created.");
	
	// Insert code here to initialize your application 
	game = [[Game alloc] init];
	
	[gameView setGame:game];
	[gameView play];
	// 
	// music = [[Music alloc] initWithFilename:@"test_music.ogg"];
	// [music play];
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

- (IBAction)toggleMusic:(id)sender;
{
	if([music isPlaying]){
		[music stop];
	} else {
		[music play];
	}
}

- (IBAction)toggleEditor:(id)sender {
	if (game.mode == GAME_MODE) {
		game.mode = EDITOR_MODE;
		[self openMap:self];
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
