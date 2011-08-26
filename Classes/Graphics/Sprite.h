#import <Cocoa/Cocoa.h>
#import "Texture.h"
#import "Types.h"

@interface Sprite : NSObject {
	Texture *texture;
	pixelRect texRect;
}

- (id)initWithTexture:(Texture *)newTexture texRect:(pixelRect)newTexRect;
- (void)drawAt:(pixelCoords)point;
- (void)drawAt:(pixelCoords)point angle:(float)angle;

- (pixelSize)size;

@end
