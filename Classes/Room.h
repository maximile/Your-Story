#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Layer.h"

@interface Room : NSObject {	
	NSMutableArray *layers;
	Layer *mainLayer;
	
	// dictionary so that if more than one layer uses the same tile map we only load it once:
	NSMutableDictionary *maps;
}

// layers, in order front to back:
@property (readonly) NSArray *layers;
// the layer that the player interacts with
@property (readonly) Layer *mainLayer;


- (TileMap *)getMap:(NSString *)mapName;
- (id)initWithName:(NSString *)roomName;

@end
