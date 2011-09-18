#import <Cocoa/Cocoa.h>
#import "Sprite.h"
#import "PhysicsObject.h"

@interface Parasprite : PhysicsObject {
	Sprite *bodySprite;
	Sprite *wingsOneSprite;
	Sprite *wingsTwoSprite;
	Sprite *feetSprite;
	Sprite *eyesSprite;
	
	cpShape *shape;
	
	int tick;
}

@end
