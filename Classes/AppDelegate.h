//
//  UntitledAppDelegate.h
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"
#import "Game.h"
#import "EditorPanel.h"

@interface AppDelegate : NSObject {
    NSWindow *window;
    EditorPanel *editorPanel;
	GameView *gameView;
	Game *game;
}

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)toggleEditor:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet EditorPanel *editorPanel;
@property (assign) IBOutlet GameView *gameView;

@end
