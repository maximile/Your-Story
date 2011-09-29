#import <Cocoa/Cocoa.h>
#import "Sprite.h"
#import "Player.h"

@interface Rocket : Player {
	Sprite *sprite;
	
	cpShape *mainShape;
	cpShape *coneShape;
}

@end
