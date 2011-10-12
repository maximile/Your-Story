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
@class Message;

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
	int coinCount;
	
	float timeTaken;
	float completionTime;
	Message *timeLabel;
	Message *completionLabel1;
	Message *completionLabel2;
	Message *completionLabel3;
	
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
	
	NSMutableArray *streetLights;
	
	Music *music;
	NSString *musicName;
	
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
@property (readonly) NSMutableArray *streetLights;

@property int coinCount;

+ (Game *)game;

- (void)drawOnCanvas:(FBO *)canvas;
- (void)update;

- (void)saveState;
- (void)restoreState;
- (void)setCurrentRoom:(Room *)newRoom fromEdge:(directionMask)edge;
- (void)setCurrentRoomFromPath:(NSString *)path;
- (void)writeCurrentRoomToPath:(NSString *)path;
- (NSString *)roomNameInDirection:(directionMask)direction;

@end
