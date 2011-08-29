#import "Spawn.h"

@implementation Spawn

@synthesize edge;

+ (Spawn *)getSpawnForEdge:(directionMask)testEdge spawns:(NSArray *)spawns {
	if (spawns.count < 1) return nil;
	
	if (testEdge == NOWHERE) {
		for (Spawn *spawn in spawns) {
			if (spawn.edge == NOWHERE) return spawn;
		}
		return [spawns objectAtIndex:0];
	}
	
	for (Spawn *spawn in spawns) {
		if (spawn.edge & testEdge) return spawn;
	}
	return [spawns objectAtIndex:0];
}

- (id)initWithPosition:(pixelCoords)newPosition {
	if ([super initWithPosition:newPosition] == nil) return nil;
	
	edge = NOWHERE;
	Room *room = [Game game].currentRoom;
	if (newPosition.x < TILE_SIZE) edge |= LEFT;
	if (newPosition.y < TILE_SIZE) edge |= DOWN;
	if (newPosition.x > ((room.size.width - 1) * TILE_SIZE)) edge |= RIGHT;
	if (newPosition.y > ((room.size.height - 1) * TILE_SIZE)) edge |= UP;
	
	return self;
}

@end
