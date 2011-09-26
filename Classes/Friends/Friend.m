#import "Friend.h"
#import "Game+Items.h"

@implementation Friend

- (void)draw:(Game *)game {
	Sprite *sprite = [sprites objectAtIndex:frameIndex];
	[sprite drawAt:self.startingPosition];
}

- (void)update:(Game *)game {
	frameTime += FIXED_DT;
	if (frameTime >= frameTimes[frameIndex]) {
		frameIndex ++;
		if (frameIndex >= sprites.count) frameIndex = 0;
		frameTime=0;
	}
}

- (void)removeMessage:(Game *)game {
	if (currentMessage != nil) {
		[game removeItem:currentMessage];
		currentMessage = nil;
	}
}

- (void)displayMessage:(Game *)game {
	if (currentMessage != nil) {
		[game removeItem:currentMessage];
		currentMessage = nil;
	}
	
	NSString *messageString = [dialogue objectAtIndex:dialogueIndex];
	pixelCoords messagePos = pixelCoordsMake(self.startingPosition.x, self.startingPosition.y + 20);
	Font *messageFont = [Font fontNamed:@"Geneva9"];
	Message *newMessage = [[Message alloc] initWithPosition:messagePos font:messageFont string:messageString];
	newMessage.alignment = NSCenterTextAlignment;
	currentMessage = newMessage;
	[game addItem:newMessage];
	
	dialogueIndex++;
	if (dialogueIndex >= dialogue.count) {
		dialogueIndex = 0;
	}
}

@end
