#import "EditorPanel.h"


@implementation EditorPanel

@synthesize paletteView;

- (void)setLayer:(Layer *)newLayer {
	[paletteView setLayer:newLayer];
}

@end
