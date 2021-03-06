#import "Types.h"

#define TILE_SIZE 16
#define CANVAS_SIZE (pixelSize){340, 280}
#define NO_TILE (mapCoords){-1,-1}

#define FIXED_DT (1.0/120.0)
#define MAX_FRAMESKIP 10

#define GRAVITY 1000.0
#define COLLISION_SLOP 0.1

typedef enum {
	PLAYER,
	ENEMY,
	GUN_DAMAGE_AREA
} collisionType;
