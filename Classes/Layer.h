#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Types.h"

@interface Layer : NSObject {
	// an array of tiles for the layer, each tile represented by
	// the coordinates of the corresponding tile on the map
	mapCoords *tiles;
	mapSize size;

	TileMap *map;
	float parallax;
}

@property mapSize size;
@property float parallax;

// - (id)initWithString:(NSString *)string map:(TileMap *)newMap;
// - (id)initWithString:(NSString *)string map:(TileMap *)newMap parallax:(float)newParallax;
- (id)initWithDictionary:(NSDictionary *)infoDict;
- (void)drawRect:(mapRect)rect;
- (void)drawCollision;

- (void)setTile:(mapCoords)tile at:(mapCoords)loc;
- (mapCoords)tileAt:(mapCoords)loc;
- (void)setTilesFromString:(NSString *)string;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)tilesString;


@end
