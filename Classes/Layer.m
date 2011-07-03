//
//  Layer.m
//  Your Story
//
//  Created by Max Williams on 03/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Layer.h"


@implementation Layer

- (id)initWithString:(NSString *)string map:(TileMap *)newMap {
	if ([super init] == nil) return nil;
		
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
	
	NSLog(@"%@", rows);
	
	// check that all rows are the same length
	if (rows.count < 1) {
		NSLog(@"No rows in string.");
		return nil;
	}
	int rowLength = [[rows objectAtIndex:0] count];
	for (NSArray *row in rows) {
		if (row.count != rowLength) {
			NSLog(@"All rows must be the same length.");
			return nil;
		}
	}
	
	// now make the tile data
	width = rowLength;
	height = rows.count;
	tiles = calloc(width*height, sizeof(tileCoords));
	
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
				tiles[index] = tileCoordsMake(xCoord, yCoord);
			}
		}
	}
	
	map = [newMap retain];
	
	return self;
}

- (void)draw {
	for (int y=0; y<height; y++) {
		for (int x=0; x<width; x++) {
			int index = y*width + x;
			tileCoords coords = tiles[index];
			NSLog(@"%i", index);
			NSLog(@"%i, %i", coords.x, coords.y);
			if (coords.x < 0 || coords.y < 0) {
				continue;
			}
			tileCoords loc = tileCoordsMake(x, y);
			[map drawTile:coords at:loc];
		}
	}
}

- (void)dealloc {
	free(tiles);
	[map release];
	[super dealloc];
}

@end
