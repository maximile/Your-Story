
#import <Cocoa/Cocoa.h>


@interface FBO : NSObject {
	GLuint name;
	GLuint textureName;
	unsigned int textureWidth;
	unsigned int textureHeight;
	unsigned int width;
	unsigned int height;
}

+ (void)bindFramebuffer:(FBO *)buffer;

- (id)initWithWidth:(int)width height:(int)height;
- (void)drawInRect:(NSRect)rect;

@property (readonly) unsigned int width;
@property (readonly) unsigned int height;
@property (readonly) unsigned int textureWidth;
@property (readonly) unsigned int textureHeight;
@property (readonly) GLuint name;

@end
