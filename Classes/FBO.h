#import <Cocoa/Cocoa.h>
#import "Types.h"

@interface FBO : NSObject {
	GLuint name;
	GLuint textureName;
	pixelSize size;
	pixelSize textureSize;
}

+ (void)bindFramebuffer:(FBO *)buffer;

- (id)initWithSize:(pixelSize)newSize;
- (void)drawInRect:(pixelRect)rect;

@property (readonly) pixelSize size;
@property (readonly) pixelSize textureSize;
@property (readonly) GLuint name;

@end
