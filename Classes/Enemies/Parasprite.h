#import <Cocoa/Cocoa.h>
#import "Sprite.h"
#import "PhysicsObject.h"

@interface Parasprite : PhysicsObject {
	Sprite *bodySprite;
	Sprite *wingsOneSprite;
	Sprite *wingsTwoSprite;
	Sprite *feetSprite;
	Sprite *eyesSprite;
	Sprite *loveSprite;
	
	cpShape *shape;
	
	int tick;
	BOOL seenPlayer;
	
	float health;
}

@end
