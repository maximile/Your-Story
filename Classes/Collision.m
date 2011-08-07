#import "Constants.h"
#import "Collision.h"
#import "TileMap.h"

@implementation Collision

static Collision *sharedCollision = nil;

@synthesize collisionMap, collisionMapSize;

+ (Collision *)collision {
	if (sharedCollision != nil) {
		return sharedCollision;
	}

	sharedCollision = [[Collision alloc] init];
	return sharedCollision;
}

- (id)init {
	if ([super init] == nil) return nil;
	
	NSImage *collisionImage = [NSImage imageNamed:@"Collision Shapes"];
	NSBitmapImageRep *collisionBitmap = [NSBitmapImageRep imageRepWithData:[collisionImage TIFFRepresentation]];
	
	// allocate space for collision map
	collisionMapSize = pixelSizeMake(collisionBitmap.size.width, collisionBitmap.size.height);
	collisionMap = calloc(collisionMapSize.width * collisionMapSize.height, sizeof(unsigned short));
	
	// set 1 or 0 for every pixel in the collision data, depending on source image's brightness
	for (int y=0; y < collisionMapSize.height; y++) {
		for (int x=0; x < collisionMapSize.width; x++) {
			NSColor *pixelColor = [collisionBitmap colorAtX:x y:y];
			float brightness = [pixelColor whiteComponent];
			int value = (brightness>0.5) ? 1 : 0;
			collisionMap[y*collisionMapSize.width+x] = value;
		}
	}
	
	// get collision entries
	NSArray *info;
	NSString *errorDesc = nil;
	NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"Collision Data" ofType:@"plist"];
	NSData *infoXML = [[NSFileManager defaultManager] contentsAtPath:infoPath];
	info = (NSArray *)[NSPropertyListSerialization propertyListFromData:infoXML mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorDesc];
	if (errorDesc != nil) {
	 	NSLog(@"%@",errorDesc);
		return nil;
	}
	
	shapes = [[NSMutableArray alloc] initWithCapacity:info.count];
	
	for (NSDictionary *collisionEntry in info) {
		NSString *tileString = [collisionEntry valueForKey:@"Tile"];
		mapCoords coords = [TileMap mapCoordsFromString:tileString];
		
		NSString *shapeString = [collisionEntry valueForKey:@"Shape"];
		CollisionShape *shape = [[CollisionShape alloc] initWithTile:coords shapeString:shapeString];
		[shapes addObject:shape];
	}
	
	return self;
}

- (CollisionShape *)shapeForTile:(mapCoords)coords {
	for (CollisionShape *shape in shapes) {
		mapCoords shapeTile = shape.tile;
		if (shapeTile.x == coords.x && shapeTile.y == coords.y) {
			return shape;
		}
 	}
	return nil;
}

+ (CollisionShape *)shapeForCoords:(mapCoords)coords data:(unsigned short *)data dataSize:(pixelSize)dataSize {
	Collision *collision = [Collision collision];
	unsigned short *collisionMap = collision.collisionMap;
	int colWidth = collision.collisionMapSize.width;
	int colTilesWide = collision.collisionMapSize.width / TILE_SIZE;
	int colTilesHigh = collision.collisionMapSize.height / TILE_SIZE;
	int dataWidth = dataSize.width;
	
	CollisionShape *closestShape = nil;
	int lowestDiff = TILE_SIZE * TILE_SIZE;
	
	// check against every collision tile
	for (int colTileY = 0; colTileY < colTilesHigh; colTileY++) {
		for (int colTileX = 0; colTileX < colTilesWide; colTileX++) {
			if (lowestDiff == 0) continue;  // skip if already found an exact match
			
			// make sure there's collision data for this tile
			CollisionShape *referenceShape = [collision shapeForTile:mapCoordsMake(colTileX, colTileY)];
			if (referenceShape == nil) continue;
			
			int diff = 0;
			
			int left = coords.x * TILE_SIZE;
			int top = coords.y * TILE_SIZE;
			int colLeft = colTileX * TILE_SIZE;
			int colTop = colTileY * TILE_SIZE;
			// compare every pixel
			for (int py = 0; py < TILE_SIZE; py++) {
				for (int px = 0; px < TILE_SIZE; px++) {
					int tilePixelX = left + px;
					int tilePixelY = top + py;
					int colPixelX = colLeft + px;
					int colPixelY = colTop + py;
					
					unsigned short tilePixel = data[tilePixelY * dataWidth + tilePixelX];
					unsigned short colPixel = collisionMap[colPixelY * colWidth + colPixelX];
					
					// ignore 1px lines; check for more than two neighbouring pixels
					if (colPixel == 1) {
						int neighbourCount = 0;
						for (int ny = -1; ny <= 1; ny++) {
							if (py + ny < 0) continue;
							if (py + ny >= TILE_SIZE) continue;
							for (int nx = -1; nx <= 1; nx++) {
								if (px + nx < 0) continue;
								if (px + nx >= TILE_SIZE) continue;
								if (nx == 0 && ny == 0) continue;
								
								// check the offset pixel
								if (data[(top + py + nx) * dataWidth + (left + px + nx)] & 1) {
									neighbourCount++;
								}
							}
						}
						if (neighbourCount < 3) {
							// fewer than two nighbouring pixels; assume it's part of a 1px line
							tilePixel = 0;
						}
					}
					
					if ((tilePixel & 1) != colPixel) {
						diff++;
					}
				}
			}
			
			if (diff < lowestDiff) {
				// it's a better match
				lowestDiff = diff;
				closestShape = referenceShape;
			}
		}
	}
		
	return closestShape;
}

@end



@implementation CollisionShape

@synthesize tile, shapeVerts, shapeVertCount;

- (id)initWithTile:(mapCoords)newTileCoords shapeString:(NSString *)string {
	[super init];
	
	tile = newTileCoords;
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSArray *tempVerts = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSMutableArray *verts = [NSMutableArray arrayWithCapacity:tempVerts.count];
	for (NSString *tempVert in tempVerts) {
		if (tempVert.length > 0) [verts addObject:tempVert];
	}
	shapeVertCount = verts.count;
	shapeVerts = calloc(shapeVertCount, sizeof(pixelCoords));
	int index = 0;
	for (NSString *vertString in verts) {
		mapCoords coordsFromString = [TileMap mapCoordsFromString:vertString];
		shapeVerts[index] = pixelCoordsMake(coordsFromString.x, coordsFromString.y);
		index++;
	}
	
	return self;
}

@end