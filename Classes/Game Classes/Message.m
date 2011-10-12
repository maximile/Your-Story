#import "Message.h"
#import "Game+Items.h"

@implementation Message

@synthesize alignment, ticker, life, screenSpace, string;

- (id)initWithPosition:(pixelCoords)position font:(Font *)newFont string:(NSString *)newString {
	if ([super initWithPosition:position] == nil) return nil;
	
	font = newFont;
	string = newString;
	
	return self;
}

- (void)draw:(Game *)game {
	if (!screenSpace)
		[font drawString:string at:startingPosition alignment:alignment];
}

- (void)drawInScreenCoords:(Game *)game {
	if (screenSpace)
		[font drawString:string at:startingPosition alignment:alignment];
}

- (void)update:(Game *)game {
	age += FIXED_DT;
	if (life > 0 && age > life) {
		[game removeItem:self];
	}
}

@end
