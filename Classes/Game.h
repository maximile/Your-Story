#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Player.h"
#import "Types.h"

typedef enum {
	GAME_MODE,
	EDITOR_MODE
} gameMode;

@interface Game : NSObject {
	gameMode mode;

	Room *currentRoom;
	
	NSMutableArray *items;
	Player *player;
	
	int upKeyCount, downKeyCount, leftKeyCount, rightKeyCount;
}

- (void)draw;
- (void)update;

- (mapCoords)cameraTargetForFocus:(NSPoint)focus;
- (void)drawEditor;
- (void)drawGame;

- (void)upUp;
- (void)leftUp;
- (void)downUp;
- (void)rightUp;
- (void)upDown;
- (void)downDown;
- (void)leftDown;
- (void)rightDown;

@end
