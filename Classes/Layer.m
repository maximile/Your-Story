#import "Layer.h"

@implementation Layer

@synthesize size, parallax;

- (NSString *)tilesString {
	NSMutableString *stringRep = [NSMutableString stringWithCapacity:0];
	for (int y = 0; y < size.height; y++) {
		for (int x = 0; x < size.height; x++) {
			mapCoords tile = [self tileAt:mapCoordsMake(x, y)];
			NSString *tileString = [NSString stringWithFormat:@"%i,%i", tile.x, tile.y];
			[stringRep appendString:tileString];
			[stringRep appendString:@" "];
		}
		[stringRep appendString:@"\n"];
	}
	return [stringRep copy];
}

- (void)setTile:(mapCoords)tile at:(mapCoords)loc {
	tiles[loc.y * size.width + loc.x] = tile;
}

- (mapCoords)tileAt:(mapCoords)loc {
	return tiles[loc.y * size.width + loc.x];
}

- (id)initWithDictionary:(NSDictionary *)info {
	if ([super init] == nil) return nil;
	
	// set map
	id mapId = [info valueForKey:@"Map"];
	if ([mapId isKindOfClass:[TileMap class]]) {
		map = (TileMap *)mapId;
	}
	else {
		map = [TileMap mapNamed:(NSString *)mapId];	
	}
		
	// set parallax
	parallax = 1.0;
	id parallaxValue = [info valueForKey:@"Parallax"];
	if (parallaxValue) {
		parallax = [parallaxValue floatValue];
	}
	
	// set tile data
	NSString *tileString = [info valueForKey:@"Tiles"];
	[self setTilesFromString:tileString];
	
	return self;
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	[info setValue:map.name forKey:@"Map"];
	if (parallax != 1.0)
		[info setValue:[NSNumber numberWithFloat:parallax] forKey:@"Parallax"];
	[info setValue:[self tilesString] forKey:@"Tiles"];
	return info;
}

- (void)setTilesFromString:(NSString *)string {	
	// build some heavy Obj-C data up first to check integrity
	NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray *rows = [NSMutableArray arrayWithCapacity:lines.count];
	for (NSString *line in lines) {
		line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if (line.length < 1) {
			// empty line; ignore it
			continue;
		}
		
		NSMutableArray *tileArray = [NSMutableArray arrayWithCapacity:0];
		[rows addObject:tileArray];
		NSArray *tileStrings = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		for (NSString *tileString in tileStrings) {
			// skip any that are just whitespace
			tileString = [tileString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (tileString.length < 1) {
				continue;
			}
			
			// parse coords
			NSArray *components = [tileString componentsSeparatedByString:@","];
			if (components.count != 2) {
				[tileArray addObject:[NSDictionary dictionary]];
			}
			else {
				NSNumber *xNumber = [NSNumber numberWithInt:[[components objectAtIndex:0] intValue]];
				NSNumber *yNumber = [NSNumber numberWithInt:[[components objectAtIndex:1] intValue]];
				NSDictionary *tileDict = [NSDictionary dictionaryWithObjectsAndKeys:xNumber, @"x", yNumber, @"y", nil];
				[tileArray addObject:tileDict];
			}
		}
	}
		
	// check that all rows are the same length
	if (rows.count < 1) {
		NSLog(@"No rows in string.");
	}
	int rowLength = [[rows objectAtIndex:0] count];
	for (NSArray *row in rows) {
		if (row.count != rowLength) {
			NSLog(@"All rows must be the same length.");
		}
	}
	
	// now make the tile data
	int width = rowLength;
	int height = rows.count;
	size = mapSizeMake(width, height);
	tiles = calloc(width*height, sizeof(mapCoords));
	
	for (int y=0; y<height; y++) {
		for (int x=0; x<width; x++) {
			int index = y*width + x;
			NSDictionary *tileInfo = [[rows objectAtIndex:y] objectAtIndex:x];
			if (tileInfo.count == 0) {
				tiles[index] = NO_TILE;
			}
			else {
				int xCoord = [[tileInfo valueForKey:@"x"] intValue];
				int yCoord = [[tileInfo valueForKey:@"y"] intValue];
				tiles[index] = mapCoordsMake(xCoord, yCoord);
			}
		}
	}
}

- (Layer *)makePaletteLayer {
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
	[info setValue:map forKey:@"Map"];
	
	NSMutableString *tilesString = [NSMutableString stringWithCapacity:0];
	for (int y = 0; y < map.size.height; y++) {
		for (int x = 0; x < map.size.width; x++) {
			[tilesString appendString:[NSString stringWithFormat:@"%i,%i  ", x, y]];
		}
		[tilesString appendString:@"\n"];
	}
	[info setValue:tilesString forKey:@"Tiles"];
	
	return [[Layer alloc] initWithDictionary:info];
}

- (mapCoords)tileCoordsForMapCoords:(mapCoords)coords {
	// get the coordinates for the tile on the map that corresponds to the given tile on the layer
	if (parallax != 1.0) {
		// it repeats
		coords.x = coords.x % size.width;
		if (coords.x < 0) coords.x = size.width + coords.x;
		coords.y = coords.y % size.height;
		if (coords.y < 0) coords.y = size.height + coords.y;
	}
	if (coords.x < 0 || coords.y < 0 || coords.x >= size.width || coords.y >= size.height) {
		return NO_TILE;
	}
	int index = (size.height - 1 - coords.y)*size.width + coords.x;
	return tiles[index];
}

- (void)drawRect:(mapRect)rect {
	// draw the tiles specified by the given rect
	for (int y = rect.origin.y; y < rect.origin.y + rect.size.width; y++) {
		for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
			mapCoords coords = [self tileCoordsForMapCoords:mapCoordsMake(x, y)];
			if (coords.x < 0 || coords.y < 0) {
				continue;
			}
			[map drawTile:coords at:mapCoordsMake(x,y)];
		}
	}
}

- (void)drawCollision {
	// for debugging; draw lines for the collision data
	for (int y=0; y<size.height; y++) {
		for (int x=0; x<size.width; x++) {
			mapCoords coords = [self tileCoordsForMapCoords:mapCoordsMake(x, y)];
			CollisionShape *collision = [map shapeForTile:coords];
			glBegin(GL_LINE_LOOP);
			for (int i=0; i<collision.shapeVertCount; i++) {
				pixelCoords coords = collision.shapeVerts[i];
				glVertex2f(x*TILE_SIZE + coords.x, y*TILE_SIZE + coords.y);
			}
			glEnd();
		}
	}
}

- (void)finalize {
	free(tiles);
	[super finalize];
}

@end
