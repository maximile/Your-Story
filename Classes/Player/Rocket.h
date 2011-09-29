#import <Cocoa/Cocoa.h>
#import "Sprite.h"
#import "Player.h"

@interface Rocket : Player {
	Sprite *sprite;
	NSArray *exhaustSprites;
	
	cpShape *mainShape;
	cpShape *coneShape;
	
	cpBody *staticBody;
	cpConstraint *rotaryLimit;
}

@end
