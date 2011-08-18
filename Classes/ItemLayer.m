#import "ItemLayer.h"
#import "Item.h"

@implementation ItemLayer

- (id)initWithDictionary:(NSDictionary *)info {
	if ([super initWithDictionary:info] == nil) return nil;
	
	map = [TileMap mapNamed:@"ItemTiles"];
	
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
			NSString *mapCoordsString = [NSString stringWithFormat:@"%i,%i"];
			
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
			Item *newItem = [[itemClass alloc] initWithPosition:mapCoordsMake(x, y)];
			[items addObject:newItem];
		}
	}
	
	return items;
}

@end
