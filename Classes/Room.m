//
//  Room.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Room.h"


@implementation Room

@synthesize size, mainLayer, bgLayer;

- (id)initWithName:(NSString *)roomName {
	if ([super init]==nil) return nil;
	
	maps = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	// populate dictionary from plist
	NSDictionary *info;
	NSString *errorDesc = nil;
	NSString *infoPath = [[NSBundle mainBundle] pathForResource:roomName ofType:@"plist"];
	NSData *infoXML = [[NSFileManager defaultManager] contentsAtPath:infoPath];
	info = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:infoXML mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorDesc];
	if (errorDesc != nil) {
	 	NSLog(@"%@",errorDesc);
		return nil;
	}
	
	// create the layers specified in the plist
	NSString *mainMapName = [info valueForKey:@"MainMap"];
	mainMap = [self getMap:mainMapName];
	NSString *mainLayerString = [info valueForKey:@"MainLayer"];
	mainLayer = [[Layer alloc] initWithString:mainLayerString map:mainMap];
	size = mainLayer.size;
	
	if ([info valueForKey:@"BGLayer"]) {
		bgMap = [self getMap:[info valueForKey:@"BGMap"]];
		NSString *bgLayerString = [info valueForKey:@"BGLayer"];
		bgLayer = [[Layer alloc] initWithString:bgLayerString map:bgMap];
		bgParallax = 1.0;
		if ([info valueForKey:@"BGParallax"]) {
			bgParallax = [[info valueForKey:@"BGParallax"] floatValue];
		}
		bgLayer.parallax = bgParallax;
	}
	
	return self;
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
