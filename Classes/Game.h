#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Player.h"
#import "Types.h"
#import "TileMap.h"
#import "chipmunk.h"

typedef enum {
	GAME_MODE,
	EDITOR_MODE
} gameMode;

@interface Game : NSObject {
	gameMode mode;

	Room *currentRoom;
	
	// game variables
	NSMutableArray *items;
	Player *player;
	
	// editor variables
	cpVect editorFocus;
	Layer *editingLayer;
	Layer *palette;
	BOOL showPalette;
	mapCoords paletteTile;
	TileMap *uiMap;
	mapCoords cursorLoc;
	
	// key pressed flags
	BOOL upKey, downKey, leftKey, rightKey, tabKey;
	
	// physics variables
	cpSpace *space;
}

@property gameMode mode;
@property (assign) Room *currentRoom;
@property (assign) Layer *editingLayer;
@property mapCoords cursorLoc;

- (void)draw;
- (void)update;

- (mapCoords)cameraTargetForFocus:(cpVect)focus;
- (void)drawGame;

- (void)upUp;
- (void)leftUp;
- (void)downUp;
- (void)rightUp;
- (void)upDown;
- (void)downDown;
- (void)leftDown;
- (void)rightDown;

- (void)tabDown;
- (void)tabUp;

- (void)numberDown:(int)number;

- (void)mouseDown:(pixelCoords)coords;
- (void)mouseDragged:(pixelCoords)coords;
- (void)mouseMoved:(pixelCoords)coords;

- (void)setCurrentRoomFromPath:(NSString *)path;
- (void)writeCurrentRoomToPath:(NSString *)path;

@end
