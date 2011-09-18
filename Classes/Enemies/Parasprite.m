#import "Parasprite.h"
#import "RandomTools.h"

@implementation Parasprite

- (id)initWithPosition:(pixelCoords)position {
	if ([super init]==nil) return nil;
	
	body = cpBodyNew(2, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	
	shape = cpCircleShapeNew(body, 4, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.2);
	cpShapeSetGroup(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	pixelRect bodyCoords;
	NSLog(@"%i", randomInt(0,3));
	switch (randomInt(0,3)) {
		case 0: bodyCoords = pixelRectMake(97, 1, 9, 9); break;
		case 1: bodyCoords = pixelRectMake(108, 1, 9, 9); break;
		case 2: bodyCoords = pixelRectMake(97, 12, 9, 9); break;
		default: bodyCoords = pixelRectMake(108, 12, 9, 9); break;
	}
	bodySprite = [[Sprite alloc] initWithTexture:texture texRect:bodyCoords];
	eyesSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 23, 9, 5)];
	feetSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(110, 25, 5, 2)];
	wingsOneSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 42, 11, 10)];
	wingsTwoSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 30, 23, 10)];
	
	return self;
}

- (void)draw:(Game *)game {	
	pixelCoords pixelPos = self.pixelPosition;
	
	// draw wings
	pixelCoords wingPos = pixelCoordsMake(pixelPos.x, pixelPos.y + 6);
	Sprite *wingsSprite;
	if (cpfsin(64.0*(game.fixedTime + self.objectPhase)) > 0)
		wingsSprite = wingsOneSprite;
	else
		wingsSprite = wingsTwoSprite;
	[wingsSprite drawAt:wingPos];
	
	[bodySprite drawAt:pixelPos];
	[eyesSprite drawAt:pixelPos];
	[feetSprite drawAt:pixelCoordsMake(pixelPos.x, pixelPos.y -4)];
}

- (void)update:(Game *)game {
	tick++;
}

- (void)finalize {
	cpShapeFree(shape);
	cpBodyFree(body);
}

@end
