#import "Room.h"
#import "ItemLayer.h"

@implementation Room

@synthesize layers, mainLayer, itemLayer, size, name;

- (id)initWithName:(NSString *)roomName {
	NSString *roomFilePath = [[NSBundle mainBundle] pathForResource:roomName ofType:@"ysroom"];
	if ([self initWithFile:roomFilePath] == nil) return nil;
	return self;
}

- (id)initWithFile:(NSString *)path {
	if ([super init]==nil) return nil;
	
	name = [[path lastPathComponent] stringByDeletingPathExtension];
	
	// dictionary to cache maps used
	maps = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// get size
	NSString *sizeString = [info valueForKey:@"Size"];
	NSArray *components = [sizeString componentsSeparatedByString:@","];
	size = mapSizeMake([[components objectAtIndex:0] intValue], [[components objectAtIndex:1] intValue]);
	NSLog(@"%i, %i", size.width, size.height);
	
	// create layer objects
	layers = [NSMutableArray arrayWithCapacity:0];
	for (NSDictionary *layerInfo in [info valueForKey:@"Layers"]) {
		if ([[layerInfo valueForKey:@"Items"] boolValue]) {
			// special layer for locating items; don't add to array
			itemLayer = [[ItemLayer alloc] initWithDictionary:layerInfo size:size];
			continue;
		}
		Layer *layer = [[Layer alloc] initWithDictionary:layerInfo size:size];
		[layers addObject:layer];
		if ([[layerInfo valueForKey:@"Main"] boolValue]) {
			mainLayer = layer;
		}
	}
	
	if (itemLayer == nil) {
		itemLayer = [[ItemLayer alloc] initWithDictionary:nil size:size];
	}  
	
	if (size.width < 1 || size.height < 1) {
		size = mainLayer.size;
	}
	
	return self;
}

- (void)writeToFile:(NSString *)path {
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	NSMutableArray *layerArray = [NSMutableArray arrayWithCapacity:layers.count];
	for (Layer *layer in layers) {
		NSMutableDictionary *layerInfo = [[layer dictionaryRepresentation] mutableCopy];
		if (mainLayer == layer)
			[layerInfo setValue:[NSNumber numberWithBool:YES] forKey:@"Main"];
		[layerArray addObject:layerInfo];
	}
	
	if (itemLayer) {
		NSMutableDictionary *layerInfo = [[itemLayer dictionaryRepresentation] mutableCopy];
		[layerInfo setValue:[NSNumber numberWithBool:YES] forKey:@"Items"];
		[layerInfo removeObjectForKey:@"Map"];
		[layerArray addObject:layerInfo];
	}
	
	[info setValue:layerArray forKey:@"Layers"];
	
	[info setValue:[NSString stringWithFormat:@"%i,%i", size.width, size.height] forKey:@"Size"];
	
	[info writeToFile:path atomically:NO];
}

- (TileMap *)getMap:(NSString *)mapName {
	// get the map with the given name, caching the results for future use
	if ([maps valueForKey:mapName]) {
		return [maps valueForKey:mapName];
	}
	
	TileMap *newMap = [[TileMap alloc] initWithImage:[NSImage imageNamed:mapName]];
	[maps setValue:newMap forKey:mapName];
	return newMap;
}

@end
