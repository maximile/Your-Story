#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Layer.h"
#import "ItemLayer.h"

@interface Room : NSObject {	
	NSMutableArray *layers;
	Layer *mainLayer;
	ItemLayer *itemLayer;
	mapSize size;
	NSString *name;
	
	// dictionary so that if more than one layer uses the same tile map we only load it once:
	NSMutableDictionary *maps;
}

// layers, in order front to back:
@property (readonly) NSArray *layers;
// the layer that the player interacts with
@property (readonly) Layer *mainLayer;
// special layer to locate items
@property (readonly) ItemLayer *itemLayer;

@property (readonly) mapSize size;
@property (readonly) NSString *name;

- (TileMap *)getMap:(NSString *)mapName;
- (id)initWithName:(NSString *)roomName;
- (id)initWithFile:(NSString *)path;
- (void)writeToFile:(NSString *)path;

@end
