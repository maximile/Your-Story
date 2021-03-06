#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Types.h"
#import "chipmunk.h"

struct BoundarySegment {
	cpVect a, b;
};

@interface Layer : NSObject {
@public
	mapSize size;
	TileMap *map;
	// an array of tiles for the layer, each tile represented by
	// the coordinates of the corresponding tile on the map
	mapCoords *tiles;

@private
	float parallax;
	// collision data
	int segmentCount;
	struct BoundarySegment *segments;
	cpShape **shapes;
}

@property mapSize size;
@property float parallax;

// - (id)initWithString:(NSString *)string map:(TileMap *)newMap;
// - (id)initWithString:(NSString *)string map:(TileMap *)newMap parallax:(float)newParallax;
- (id)initWithDictionary:(NSDictionary *)infoDict size:(mapSize)size;
- (void)drawRect:(mapRect)rect ignoreParallax:(BOOL)ignoreParallax;

- (void)setTile:(mapCoords)tile at:(mapCoords)loc;
- (mapCoords)tileAt:(mapCoords)loc;
- (void)setTilesFromString:(NSString *)string;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)tilesString;
- (Layer *)makePaletteLayer;

- (mapCoords)tileCoordsForMapCoords:(mapCoords)coords ignoreParallax:(BOOL)ignoreParallax;

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;


@end
