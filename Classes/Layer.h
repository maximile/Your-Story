#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Types.h"
#import "chipmunk.h"

@interface Layer : NSObject {
	// an array of tiles for the layer, each tile represented by
	// the coordinates of the corresponding tile on the map
	mapCoords *tiles;
	mapSize size;

	TileMap *map;
	float parallax;
	
	// collision data
	cpShape **shapes;
	int shapeCount;
}

@property mapSize size;
@property float parallax;

// - (id)initWithString:(NSString *)string map:(TileMap *)newMap;
// - (id)initWithString:(NSString *)string map:(TileMap *)newMap parallax:(float)newParallax;
- (id)initWithDictionary:(NSDictionary *)infoDict;
- (void)drawRect:(mapRect)rect ignoreParallax:(BOOL)ignoreParallax;
- (void)drawCollision;

- (void)setTile:(mapCoords)tile at:(mapCoords)loc;
- (mapCoords)tileAt:(mapCoords)loc;
- (void)setTilesFromString:(NSString *)string;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)tilesString;
- (Layer *)makePaletteLayer;

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;


@end
