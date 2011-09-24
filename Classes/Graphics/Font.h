#import <Cocoa/Cocoa.h>
#import "Texture.h"
#import "Types.h"

@interface Font : NSObject {
	Texture *texture;
	pixelRect *coords;
	pixelCoords *offsets;
	unichar *characters;
	int characterCount;
	int *widths;
	NSString *name;
	int maxHeight;
	int lineHeight;
	int spaceWidth;
	int defaultSpacing;
}

- (int)widthForString:(NSString *)string;

+ (Font *)fontNamed:(NSString *)name;
- (id)initWithDictionary:(NSDictionary *)info;
- (void)drawString:(NSString *)string at:(pixelCoords)loc alignment:(NSTextAlignment)alignment;

@end
