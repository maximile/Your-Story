#import <Cocoa/Cocoa.h>
#import "PaletteView.h"

@interface EditorPanel : NSPanel {
	PaletteView *paletteView;
}

@property (assign) IBOutlet PaletteView *paletteView;

- (void)setLayer:(Layer *)newLayer;

@end
