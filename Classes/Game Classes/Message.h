#import <Cocoa/Cocoa.h>
#import "Item.h"
#import "Font.h"

@interface Message : Item {
	Font *font;
	NSString *string;
	NSTextAlignment alignment;
	
	float life;
	BOOL ticker;
	float age;
}

@property float life;
@property BOOL ticker;
@property NSTextAlignment alignment;

- (id)initWithPosition:(pixelCoords)position font:(Font *)newFont string:(NSString *)newString;


@end
