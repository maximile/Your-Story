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
	GLuint textureName;
	
	mapSize size;  // tiles wide, tiles high
	pixelSize imageSize;  // size in pixels of the source image
	pixelSize textureSize;  // size in pixels of the texture
	
	NSMutableArray *collisionShapes;
	
	NSString *name;
}

@property (readonly) GLuint textureName;
@property (assign) NSString *name;
@property (readonly) mapSize size;

+ (TileMap *)mapNamed:(NSString *)mapName;

+ (mapCoords)mapCoordsFromString:(NSString *)string;

- (TileMap *)initWithImage:(NSImage *)image;
- (id)initWithImage:(NSImage *)image generateCollision:(BOOL)shouldGenerateCollision;
- (void)drawTile:(mapCoords)tile at:(mapCoords)loc;
- (CollisionShape *)shapeForTile:(mapCoords)coords;


@end
