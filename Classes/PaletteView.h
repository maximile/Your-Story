#import <Cocoa/Cocoa.h>
#import "Layer.h"
#import "FBO.h"

@interface PaletteView : NSOpenGLView {
	Layer *layer;
	FBO *canvasFBO;
}

@property (assign) Layer *layer;

@end
