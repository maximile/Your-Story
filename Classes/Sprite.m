#import "Sprite.h"
#import "chipmunk.h"

pixelCoords pixelCoordsRotate(pixelCoords point, cpVect angle) {
	cpVect v = cpv(point.x, point.y);
	NSLog(@"%4.2f", v.x);
	cpVect result = CGPointMake(v.x * angle.x - v.y * angle.y, v.x * angle.y + v.y * angle.x);
	NSLog(@"%4.2f", result.x);
	return pixelCoordsMake(result.x, result.y);
}

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

- (void)drawAt:(pixelCoords)point angle:(float)angle {
	pixelCoords coords[4];
	pixelCoords texCoords[4];
	cpVect rotationVector = cpvforangle(angle);
	int width = texRect.size.width;
	int height = texRect.size.height;
	
	pixelCoords tl = pixelCoordsMake(- width / 2, - height / 2);
	pixelCoords tr = pixelCoordsMake(width / 2,  - height / 2);
	pixelCoords br = pixelCoordsMake(width / 2, height / 2);
	pixelCoords bl = pixelCoordsMake(- width / 2, height / 2);
		
	coords[0] = pixelCoordsRotate(bl, rotationVector);
	coords[1] = pixelCoordsRotate(br, rotationVector);
	coords[2] = pixelCoordsRotate(tl, rotationVector);
	coords[3] = pixelCoordsRotate(tr, rotationVector);
	
	coords[0] = pixelCoordsMake(coords[0].x + point.x, coords[0].y + point.y);
	coords[1] = pixelCoordsMake(coords[1].x + point.x, coords[1].y + point.y);
	coords[2] = pixelCoordsMake(coords[2].x + point.x, coords[2].y + point.y);
	coords[3] = pixelCoordsMake(coords[3].x + point.x, coords[3].y + point.y);
	
	NSLog(@"%i, %i", coords[0].x, coords[0].y);
	
	texCoords[0] = pixelCoordsMake(texRect.origin.x, texRect.origin.y);
	texCoords[1] = pixelCoordsMake(texRect.origin.x + texRect.size.width, texRect.origin.y);
	texCoords[2] = pixelCoordsMake(texRect.origin.x, texRect.origin.y + texRect.size.height);
	texCoords[3] = pixelCoordsMake(texRect.origin.x + texRect.size.width, texRect.origin.y + texRect.size.height);

	[texture addQuad:coords texCoords:texCoords];
}


@end
