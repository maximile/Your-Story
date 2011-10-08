#import <Cocoa/Cocoa.h>
#import "PhysicsObject.h"
#import "chipmunk.h"
#import "Types.h"
#import "Sprite.h"
#import "Jumper.h"
#import "Player.h"

@interface Character : Player {
	cpShape *headShape, *feetShape;
	
	Sprite *jumpSprite;
	Sprite *normalSprite;
	Sprite *fullHealth;
	Sprite *emptyHealth;
	NSArray *walkCycle;
	NSDictionary *leftSprites;
	NSDictionary *rightSprites;
	NSArray *shotgunParticleSprites;
	Sprite *smokeParticleSprite;
	directionMask facing;
	
	// number of frames of inlvulnerability (e.g. after hitting an enemy)
	double invulnerable;
	double reloadTime;
	int shellsFired;
	
	int health;
	float battery;
	BOOL canDoubleJump;
	
	bool lastJumpKeyState;
	
	// Body you are standing on and it's normal.
	GroundingContext grounding;
	
	// Standing on ground that can be walked up.
	bool wellGrounded;
	
	// Amount of jump "boost" time remaining.
	// Gravity is not applied until boost runs out or the jump key is released.
	// This is very mario-esque.
	cpFloat remainingBoost;
	
	// Number of mid-air jumps remaining to be triggered.
	int remainingAirJumps;
	
	// remaining time you're able to jump after walking off a ledge
	float remainingJumpLeniency;
	
	// Velocity of the body last stood on
	cpVect groundVelocity;
	
	bool useShotgun;
}

@property float battery;

- (void)addToSpace:(cpSpace *)space;
- (void)removeFromSpace:(cpSpace *)space;

- (int)hitEnemy:(PhysicsObject *)enemy arbiter:(cpArbiter *)arb;
- (int)hitPickup:(Item *)pickup arbiter:(cpArbiter *)arb;

- (void)addHealth:(int)healthDiff;

@end
