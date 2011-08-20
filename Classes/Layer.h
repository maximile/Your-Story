#import <Cocoa/Cocoa.h>
#import "TileMap.h"
#import "Types.h"
#import "chipmunk.h"

@interface Layer : NSObject {
@public
	mapSize size;
	TileMap *map;

@private
	// an array of tiles for the layer, each tile represented by
	// the coordinates of the corresponding tile on the map
	mapCoords *tiles;
	
	float parallax;
	
	// collision data
	NSArray *shapes;
}

@property mapSize size;
@property float parallax;

// - (id)initWithString:(NSString *)string map:(TileMap *)newMap;
// - (id)initWithString:(NSString *)string map:(TileMap *)newMap parallax:(float)newParallax;
- (id)initWithDictionary:(NSDictionary *)infoDict;
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
