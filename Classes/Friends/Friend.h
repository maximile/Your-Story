#import <Cocoa/Cocoa.h>
#import "Item.h"
#import "Sprite.h"
#import "Message.h"

@interface Friend : Item {
	NSArray *sprites;
	float frameTime;
	float *frameTimes;
	int frameIndex;
	NSArray *dialogue;
	
	Message *currentMessage;
	
	int dialogueIndex;
}

- (void)displayMessage:(Game *)game;
- (void)removeMessage:(Game *)game;

@end
