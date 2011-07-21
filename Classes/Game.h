#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "Player.h"

typedef enum {
	GAME_MODE,
	EDITOR_MODE
} gameMode;

@interface Game : NSObject {
	gameMode mode;

	Room *currentRoom;
	NSPoint focus;
	
	NSMutableArray *items;
	Player *player;
	
	int upKeyCount, downKeyCount, leftKeyCount, rightKeyCount;
	
}

- (void)draw;
- (void)update;

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
