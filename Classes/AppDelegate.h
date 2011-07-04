//
//  UntitledAppDelegate.h
//  Untitled
//
//  Created by Max Williams on 01/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject {
    NSWindow *window;
}

- (IBAction)toggleFullScreen:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
