#import <Cocoa/Cocoa.h>
#import "Item.h"
#import "Font.h"

@interface Message : Item {
	Font *font;
	NSString *string;
	NSTextAlignment alignment;
	
	float life;
	BOOL ticker;
	BOOL screenSpace;
	float age;
}

@property float life;
@property BOOL screenSpace;
@property BOOL ticker;
@property NSTextAlignment alignment;
@property (assign) NSString *string;

- (id)initWithPosition:(pixelCoords)position font:(Font *)newFont string:(NSString *)newString;


@end
