//
//  Room.m
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Room.h"


@implementation Room

- (id)initWithName:(NSString *)roomName {
	if ([super init]==nil) return nil;

	NSDictionary *info;
	NSString *errorDesc = nil;
	NSString *infoPath = [[NSBundle mainBundle] pathForResource:roomName ofType:@"plist"];
	NSData *infoXML = [[NSFileManager defaultManager] contentsAtPath:infoPath];
	info = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:infoXML mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorDesc];
	if (errorDesc != nil) {
	 	NSLog(@"%@",errorDesc);
		return nil;
	}
	
	NSString *midMapName = [info valueForKey:@"MidMap"];
	midMap = [[TileMap alloc] initWithImage:[NSImage imageNamed:midMapName]];
	NSString *midLayerString = [info valueForKey:@"MidLayer"];
	midLayer = [[Layer alloc] initWithString:midLayerString map:midMap];
	
	return self;
}

- (void)draw {
	[midLayer draw];
	NSLog(@"awegrija");
}

- (void)dealloc {
	[midMap release];
	[midLayer release];
	[super dealloc];
}

@end
