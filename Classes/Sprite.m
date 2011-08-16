#import "Sprite.h"


@implementation Sprite

- (id)initWithTexture:(Texture *)newTexture texRect:(pixelRect)newTexRect {
	if ([super init]==nil) return nil;
	
	texture = newTexture;
	texRect = newTexRect;
	
	return self;
}

- (void)drawAt:(pixelCoords)point {			
	int width = texRect.size.width;
	int height = texRect.size.height;
	pixelRect drawRect = pixelRectMake(point.x - width / 2, point.y - height / 2, width, height);
	[texture addRect:drawRect texRect:texRect];
}


@end
