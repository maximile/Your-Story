//
//  Collision.m
//  Your Story
//
//  Created by Max Williams on 17/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Constants.h"
#import "Collision.h"
#import "TileMap.h"

@implementation Collision

static Collision *sharedCollision = nil;

@synthesize collisionMap, width, height;

+ (Collision *)collision {
	if (sharedCollision != nil) {
		return sharedCollision;
	}

	sharedCollision = [[Collision alloc] init];
	return sharedCollision;
}

- (id)init {
	[super init];
	
	NSImage *collisionImage = [NSImage imageNamed:@"Collision Shapes"];
	NSBitmapImageRep *collisionBitmap = [NSBitmapImageRep imageRepWithData:[collisionImage TIFFRepresentation]];
	
	// allocate space for collision data
	NSSize collisionSize = collisionBitmap.size;
	width = collisionSize.width;
	height = collisionSize.height;
	collisionMap = calloc(width*height, sizeof(unsigned short));
	
	// set 1 or 0 for every pixel in the collision data, depending on source image's brightness
	for (int y=0; y < height; y++) {
		for (int x=0; x < width; x++) {
			NSColor *pixelColor = [collisionBitmap colorAtX:x y:y];
			float brightness = [pixelColor whiteComponent];
			int value = (brightness>0.5) ? 1 : 0;
			collisionMap[y*width+x] = value;
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
		tileCoords coords = [TileMap tileCoordsFromString:tileString];
		
		NSString *shapeString = [collisionEntry valueForKey:@"Shape"];
		CollisionShape *shape = [[CollisionShape alloc] initWithTile:coords shapeString:shapeString];
		[shapes addObject:shape];
	}
	
	return self;
}

- (CollisionShape *)shapeForTile:(tileCoords)coords {
	for (CollisionShape *shape in shapes) {
		tileCoords shapeTile = shape.tile;
		if (shapeTile.x == coords.x && shapeTile.y == coords.y) {
			return shape;
		}
 	}
	return nil;
}

+ (CollisionShape *)shapeForCoords:(tileCoords)coords data:(unsigned short *)data dataSize:(mapSize)dataSize {
	Collision *collision = [Collision collision];
	unsigned short *collisionMap = collision.collisionMap;
	int colWidth = collision.width;
	int colTilesWide = collision.width / TILE_SIZE;
	int colTilesHigh = collision.height / TILE_SIZE;
	int dataWidth = dataSize.width;
//	int dataHeight = dataSize.height;
//	int tilesWide = dataWidth / TILE_SIZE;
//	int tilesHigh = dataHeight / TILE_SIZE;
	
	CollisionShape *closestShape = nil;
	int lowestDiff = TILE_SIZE * TILE_SIZE;
	
	// check against every collision tile
	for (int colTileY = 0; colTileY < colTilesHigh; colTileY++) {
		for (int colTileX = 0; colTileX < colTilesWide; colTileX++) {
			if (lowestDiff == 0) continue;  // skip if already found an exact match
			
			// make sure there's collision data for this tile
			CollisionShape *referenceShape = [collision shapeForTile:tileCoordsMake(colTileX, colTileY)];
			if (referenceShape == nil) continue;
			
			NSLog(@"%i %i    %i %i", coords.x, coords.y, colTileX, colTileY);
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
	
	NSLog(@"closest: %i, %i", closestShape.tile.x, closestShape.tile.y);
	
	return closestShape;
}

// + (void)generateCollisionFromData:(unsigned short *)data width:(int)dataWidth height:(int)dataHeight {
// 	Collision *collision = [Collision collision];
// 	unsigned short *collisionMap = collision.collisionMap;
// 	int colWidth = collision.width;
// 	int colTilesWide = collision.width / TILE_SIZE;
// 	int colTilesHigh = collision.height / TILE_SIZE;
// 	int tilesWide = dataWidth / TILE_SIZE;
// 	int tilesHigh = dataHeight / TILE_SIZE;
// 	
// 	// for every tile in the map:
// 	for (int tileY = 0; tileY < tilesHigh; tileY++) {
// 		for (int tileX = 0; tileX < tilesWide; tileX++) {
// 			// check against every collision tile
// 			for (int colTileY = 0; colTileY < colTilesHigh; colTileY++) {
// 				for (int colTileX = 0; colTileX < colTilesWide; colTileX++) {
// 					// make sure there's collision data for this tile
// 					CollisionShape *referenceShape = [collision shapeForTile:tileCoordsMake(colTileX, colTileY)];
// 					if (referenceShape == nil) continue;
// 					
// 					NSLog(@"%i %i    %i %i", tileX, tileY, colTileX, colTileY);
// 					int diff = 0;
// 					
// 					int left = tileX * TILE_SIZE;
// 					int top = tileY * TILE_SIZE;
// 					int colLeft = colTileX * TILE_SIZE;
// 					int colTop = colTileY * TILE_SIZE;
// 					// compare every pixel
// 					for (int py = 0; py < TILE_SIZE; py++) {
// 						for (int px = 0; px < TILE_SIZE; px++) {
// 							int tilePixelX = left + px;
// 							int tilePixelY = top + py;
// 							int colPixelX = colLeft + px;
// 							int colPixelY = colTop + py;
// 							unsigned short tilePixel = data[tilePixelY * dataWidth + tilePixelX];
// 							unsigned short colPixel = collisionMap[colPixelY * colWidth + colPixelX];
// 							if ((tilePixel & 1) != colPixel) {
// 								diff++;
// 							}
// 						}
// 					}
// 					
// 					if (diff == 0) {
// 						NSLog(@"aegirjioerw");
// 						// it's a perfect match, no need to test any more
// 					}
// 				}
// 			}
// 		}
// 	}
// }
// 

@end



@implementation CollisionShape

@synthesize tile, shapeVerts, shapeVertCount;

- (id)initWithTile:(tileCoords)newTileCoords shapeString:(NSString *)string {
	[super init];
	
	tile = newTileCoords;
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSArray *tempVerts = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSMutableArray *verts = [NSMutableArray arrayWithCapacity:tempVerts.count];
	for (NSString *tempVert in tempVerts) {
		if (tempVert.length > 0) [verts addObject:tempVert];
	}
	shapeVertCount = verts.count;
	shapeVerts = calloc(shapeVertCount, sizeof(tileCoords));
	int index = 0;
	for (NSString *vertString in verts) {
		shapeVerts[index] = [TileMap tileCoordsFromString:vertString];
		index++;
	}
	
	return self;
}

@end