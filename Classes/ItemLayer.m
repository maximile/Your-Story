#import "ItemLayer.h"
#import "Item.h"

@implementation ItemLayer

- (id)initWithDictionary:(NSDictionary *)info size:(mapSize)newSize {
	if ([info valueForKey:@"Map"] == nil) {
		info = [NSMutableDictionary dictionaryWithDictionary:info];
		[info setValue:@"ItemTiles.psd" forKey:@"Map"];
	}
	if ([super initWithDictionary:info size:newSize] == nil) return nil;
		
	return self;
}

- (NSArray *)items {
	NSString *itemClassesPath = [[NSBundle mainBundle] pathForResource:@"ItemClasses" ofType:@"plist"];
	NSDictionary *itemClasses = [NSDictionary dictionaryWithContentsOfFile:itemClassesPath];
	NSMutableArray *items = [NSMutableArray array];
	
	for (int y=0; y<size.height; y++) {
		for (int x=0; x<size.width; x++) {
			int index = y*size.width + x;
			mapCoords tileCoords = tiles[index];
			if (tileCoords.x < 0 || tileCoords.y < 0) continue;
			NSString *mapCoordsString = [NSString stringWithFormat:@"%i,%i", tileCoords.x, tileCoords.y];
			
			// check for tile with no class set
			NSString *className = [itemClasses valueForKey:mapCoordsString];
			if (className == nil) {
				NSLog(@"No class set for tile at %@", mapCoordsString);
				continue;
			}
			
			// check for unknown class
			Class itemClass = NSClassFromString(className);
			if (itemClass == nil) {
				NSLog(@"Can't find class named '%@'", className);
				continue;
			}
			
			// got a valid class; instantiate it
			pixelCoords tileCentre = pixelCoordsMake(x * TILE_SIZE + TILE_SIZE/2, (size.height - y - 1) * TILE_SIZE + TILE_SIZE/2);
			Item *newItem = [[itemClass alloc] initWithPosition:tileCentre];
			[items addObject:newItem];
		}
	}
	
	return items;
}

@end
