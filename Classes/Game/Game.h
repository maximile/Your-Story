#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Types.h"
#import "TileMap.h"
#import "chipmunk.h"

#import "FBO.h"
#import "Texture.h"
#import "Types.h"
#import "Music.h"

@class Player;
@class Door;
@class Sprite;
@class Rocket;

typedef enum {
	GAME_MODE,
	EDITOR_MODE
} gameMode;

@interface Game : NSObject {
	gameMode mode;
	NSMutableDictionary *stateDict;

	Room *currentRoom;
	
	// game variables
	NSMutableArray *items;
	NSMutableArray *itemsToAdd;
	NSMutableArray *itemsToRemove;
	
	pixelCoords cameraFocus;
	
	Player *player;
	Door *door;
	Rocket *rocket;
	NSArray *friends;
	
	// transition variables
	float transition;
	Layer *transitionLayer;
	mapCoords *transitionTiles;
	int transitionTilesCount;
	
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
	BOOL upKey, downKey, leftKey, rightKey, tabKey, zKey, xKey, shiftKey;
	BOOL wasPressingAction, wasPressingX;
	
	// physics variables
	cpSpace *space;
	
	double fixedTime;
	double lastTime;
	double accumulator;
	
	NSDictionary *connectionDict;
	NSArray *connections;
	
	Sprite *actionPrompt1Sprite;
	Sprite *actionPrompt2Sprite;
	
	FBO *lightmapCanvas;
}

@property gameMode mode;
@property (assign) Room *currentRoom;
@property (assign) Layer *editingLayer;
@property mapCoords cursorLoc;
@property (assign) Player *player;
@property (readonly) cpSpace *space;
@property (readonly) double fixedTime;
@property (readonly) NSMutableDictionary *stateDict;

+ (Game *)game;

- (void)drawOnCanvas:(FBO *)canvas;
- (void)update;

- (void)setState:(NSDictionary *)state;
- (void)setCurrentRoom:(Room *)newRoom fromEdge:(directionMask)edge;
- (void)setCurrentRoomFromPath:(NSString *)path;
- (void)writeCurrentRoomToPath:(NSString *)path;
- (NSString *)roomNameInDirection:(directionMask)direction;

@end
