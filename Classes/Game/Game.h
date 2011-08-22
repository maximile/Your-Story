#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Types.h"
#import "TileMap.h"
#import "chipmunk.h"

#import "FBO.h"
#import "Texture.h"

@class Player;

typedef enum {
	GAME_MODE,
	EDITOR_MODE
} gameMode;

@interface Game : NSObject {
	gameMode mode;

	Room *currentRoom;
	
	// game variables
	NSMutableArray *items;
	NSMutableArray *itemsToAdd;
	NSMutableArray *itemsToRemove;
	
	Player *player;
	
	// editor variables
	pixelCoords editorFocus;
	Layer *editingLayer;
	Layer *palette;
	BOOL showPalette;
	mapCoords paletteTile;
	TileMap *uiMap;
	mapCoords cursorLoc;
	BOOL drawOtherLayers;
	BOOL drawCollision;
	
	// key pressed flags
	BOOL upKey, downKey, leftKey, rightKey, tabKey, spaceKey;
	
	// physics variables
	cpSpace *space;
	
	double fixedTime;
	double lastTime;
	double accumulator;
	
	FBO *lightmapCanvas;
}

@property gameMode mode;
@property (assign) Room *currentRoom;
@property (assign) Layer *editingLayer;
@property mapCoords cursorLoc;
@property (readonly) Player *player;
@property (readonly) cpSpace *space;
@property (readonly) double fixedTime;

+ (Game *)game;

- (void)drawOnCanvas:(FBO *)canvas;
- (void)update;

- (void)setCurrentRoomFromPath:(NSString *)path;
- (void)writeCurrentRoomToPath:(NSString *)path;

@end
