// structs for dealing with tiles on a tile map

typedef struct {
	int x;
	int y;
} mapCoords;

static inline mapCoords mapCoordsMake(int x, int y) {
	return (mapCoords){x, y};
}

typedef struct {
	int width;
	int height;
} mapSize;

static inline mapSize mapSizeMake(int width, int height) {
	return (mapSize){width, height};
}

typedef struct {
	mapCoords origin;
	mapSize size;
} mapRect;

static inline mapRect mapRectMake(int originX, int originY, int width, int height) {
	return (mapRect){originX, originY, width, height};
}


// structs for dealing with areas on a bitmap

typedef struct {
	int x;
	int y;
} pixelCoords;

static inline pixelCoords pixelCoordsMake(int x, int y) {
	return (pixelCoords){x, y};
}

typedef struct {
	int width;
	int height;
} pixelSize;

static inline pixelSize pixelSizeMake(int width, int height) {
	return (pixelSize){width, height};
}

typedef struct {
	pixelCoords origin;
	pixelSize size;
} pixelRect;

static inline pixelRect pixelRectMake(int originX, int originY, int width, int height) {
	return (pixelRect){originX, originY, width, height};
}

static inline pixelRect pixelRectOffset(pixelRect rect, pixelSize offset) {
	rect.origin.x += offset.width;
	rect.origin.y += offset.height;
	return rect;
}



// direction bitmask, e.g. for arrow key input

typedef enum {
	NOWHERE = 0,
	LEFT = 1,
	RIGHT = 2,
	UP = 4,
	DOWN = 8
} directionMask;
