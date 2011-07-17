//
//  TileMap.h
//  Your Story
//
//  Created by Max Williams on 02/07/2011.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import "Constants.h"
#import "Collision.h"


@interface TileMap : NSObject {
	GLuint name;
	int width;
	int height;
	NSMutableArray *collisionShapes;
}

@property(readonly) GLuint name;

+ (tileCoords)tileCoordsFromString:(NSString *)string;

- (TileMap *)initWithImage:(NSImage *)image;
- (id)initWithImage:(NSImage *)image generateCollision:(BOOL)shouldGenerateCollision;
- (void)drawTile:(tileCoords)tile at:(tileCoords)loc;
- (CollisionShape *)shapeForTile:(tileCoords)coords;


@end
