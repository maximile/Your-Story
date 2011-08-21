#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "Constants.h"

@interface Texture : NSObject {
	GLuint textureName;
	pixelSize size;
	NSString *name;
	GLfloat* coords;
	GLfloat* texCoords;
	int quadCount;
	int slots;
}

+ (Texture *)textureNamed:(NSString *)name;
+ (NSArray *)textures;

- (id)initWithImage:(NSImage *)image;

- (void)addQuad:(pixelCoords *)quadCoords texCoords:(pixelCoords *)quadTexCoords;
- (void)addRect:(pixelRect)rect texRect:(pixelRect)texRect;
- (void)draw;

@end
