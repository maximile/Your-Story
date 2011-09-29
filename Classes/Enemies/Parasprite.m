#import "Parasprite.h"
#import "RandomTools.h"
#import "Player.h"
#import "Particle.h"
#import "Game+Items.h"

@implementation Parasprite

- (id)initWithPosition:(pixelCoords)position {
	if ([super initWithPosition:position]==nil) return nil;
	
	body = cpBodyNew(1.0, INFINITY);
	cpBodySetPos(body, cpv(position.x, position.y));
	cpBodySetUserData(body, self);
	cpBodySetVelLimit(body, 50);
	
	shape = cpCircleShapeNew(body, 6, cpvzero);
	cpShapeSetCollisionType(shape, [self class]);
	cpShapeSetFriction(shape, 0.2);
	cpShapeSetElasticity(shape, 1.0);
	cpShapeSetGroup(shape, [self class]);
	cpShapeSetUserData(shape, self);
	
	Texture *texture = [Texture textureNamed:@"MainSprites.psd"];
	pixelRect bodyCoords;
	switch (randomInt(0,5)) {
		case 0: bodyCoords = pixelRectMake(97, 1, 9, 9); break;
		case 1: bodyCoords = pixelRectMake(108, 1, 9, 9); break;
		case 2: bodyCoords = pixelRectMake(119, 1, 9, 9); break;
		case 3: bodyCoords = pixelRectMake(97, 12, 9, 9); break;
		case 4: bodyCoords = pixelRectMake(108, 12, 9, 9); break;
		default: bodyCoords = pixelRectMake(119, 12, 9, 9); break;
	}
	bodySprite = [[Sprite alloc] initWithTexture:texture texRect:bodyCoords];
	eyesSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 23, 9, 5)];
	feetSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(110, 25, 5, 2)];
	wingsOneSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 42, 11, 10)];
	wingsTwoSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(97, 30, 23, 10)];
	
	loveSprite = [[Sprite alloc] initWithTexture:texture texRect:pixelRectMake(119, 24, 7, 6)];
	
	health = 0.5;
	
	return self;
}

- (void)draw:(Game *)game {	
	pixelCoords pixelPos = self.pixelPosition;
	
	// draw wings
	float flapRate = 24.0;
	if (self.body->f.y > 2000.0) {
		flapRate = 64.0;
	}
	pixelCoords wingPos = pixelCoordsMake(pixelPos.x, pixelPos.y + 6);
	Sprite *wingsSprite;
	if (cpfsin(flapRate*(game.fixedTime + self.objectPhase)) > 0)
		wingsSprite = wingsOneSprite;
	else
		wingsSprite = wingsTwoSprite;
	[wingsSprite drawAt:wingPos];
	
	[bodySprite drawAt:pixelPos];
	[eyesSprite drawAt:pixelPos];
	[feetSprite drawAt:pixelCoordsMake(pixelPos.x, pixelPos.y -4)];
}

static const cpVect WAVER[] = {
	{-0.267,  0.964}, {-0.981, -0.195}, { 0.950, -0.314}, {-0.653,  0.757}, {-0.672,  0.741}, { 0.653, -0.757}, { 0.596,  0.803}, {-0.803, -0.596},
	{-0.000, -1.000}, {-0.615, -0.788}, {-0.428,  0.904}, { 0.989,  0.147}, { 0.171, -0.985}, {-0.267, -0.964}, { 0.773,  0.634}, {-0.989,  0.147},
	{ 0.314, -0.950}, {-0.195,  0.981}, {-0.942,  0.337}, { 0.924,  0.383}, { 0.831,  0.556}, {-0.360, -0.933}, {-0.831,  0.556}, { 0.337, -0.942},
	{ 0.243,  0.970}, { 0.514,  0.858}, {-0.025, -1.000}, { 0.981,  0.195}, {-0.405, -0.914}, {-0.556, -0.831}, {-1.000,  0.025}, { 0.904, -0.428},
	{-0.773,  0.634}, { 0.893, -0.450}, {-1.000, -0.025}, {-0.314,  0.950}, { 0.933, -0.360}, {-0.985, -0.171}, {-0.970,  0.243}, {-0.514,  0.858},
	{ 0.858,  0.514}, {-0.957,  0.290}, { 0.989, -0.147}, { 0.870, -0.493}, { 0.981, -0.195}, { 0.122,  0.992}, { 0.882, -0.471}, { 0.870,  0.493},
	{-0.471,  0.882}, {-0.997, -0.074}, {-0.914,  0.405}, { 0.576,  0.818}, { 0.337,  0.942}, { 0.672, -0.741}, { 0.999,  0.049}, {-0.724,  0.690},
	{ 0.122, -0.992}, { 0.672,  0.741}, {-0.576,  0.818}, { 0.741, -0.672}, { 0.535,  0.845}, { 0.314,  0.950}, {-0.870,  0.493}, {-0.596, -0.803},
	{-0.964,  0.267}, { 0.724,  0.690}, {-0.803,  0.596}, {-0.098,  0.995}, {-0.985,  0.171}, { 0.535, -0.845}, {-0.992, -0.122}, {-0.999,  0.049},
	{-0.858, -0.514}, {-0.383,  0.924}, {-0.831, -0.556}, {-0.893, -0.450}, {-0.924,  0.383}, { 0.615,  0.788}, {-0.999, -0.049}, {-0.596,  0.803},
	{ 0.000,  1.000}, { 0.985,  0.171}, {-0.074,  0.997}, { 0.450,  0.893}, { 0.098,  0.995}, {-0.098, -0.995}, { 0.924, -0.383}, { 0.942,  0.337},
	{ 0.803, -0.596}, {-0.924, -0.383}, { 0.493,  0.870}, { 0.773, -0.634}, {-0.690, -0.724}, {-0.904, -0.428}, { 0.074, -0.997}, {-0.634,  0.773},
	{ 0.858, -0.514}, { 0.757, -0.653}, { 0.788,  0.615}, {-0.171,  0.985}, {-0.471, -0.882}, {-0.243, -0.970}, {-0.383, -0.924}, { 0.195, -0.981},
	{ 0.405,  0.914}, {-0.049,  0.999}, { 0.383,  0.924}, {-0.514, -0.858}, {-0.122,  0.992}, { 0.147, -0.989}, { 0.724, -0.690}, {-0.904,  0.428},
	{ 0.690,  0.724}, {-0.690,  0.724}, {-0.147, -0.989}, { 0.999, -0.049}, { 0.964,  0.267}, { 0.893,  0.450}, { 0.098, -0.995}, { 0.615, -0.788},
	{ 0.707,  0.707}, {-0.893,  0.450}, {-0.942, -0.337}, { 0.471, -0.882}, {-0.845,  0.535}, {-0.757,  0.653}, { 0.741,  0.672}, {-0.995,  0.098},
	{-0.997,  0.074}, { 0.845, -0.535}, {-0.914, -0.405}, { 0.757,  0.653}, { 0.992,  0.122}, { 0.049,  0.999}, {-0.049, -0.999}, {-0.773, -0.634},
	{ 0.976,  0.219}, {-0.615,  0.788}, {-0.195, -0.981}, {-0.450,  0.893}, { 0.383, -0.924}, {-0.535,  0.845}, { 0.025,  1.000}, { 0.267, -0.964},
	{-0.672, -0.741}, { 0.556, -0.831}, {-0.970, -0.243}, {-0.290,  0.957}, {-0.788,  0.615}, { 0.818,  0.576}, {-0.428, -0.904}, { 0.556,  0.831},
	{ 1.000, -0.025}, { 0.596, -0.803}, {-0.122, -0.992}, {-0.337,  0.942}, {-0.882,  0.471}, { 0.997, -0.074}, { 0.957,  0.290}, {-0.950, -0.314},
	{ 0.243, -0.970}, {-0.634, -0.773}, {-0.933, -0.360}, {-0.818, -0.576}, {-0.219,  0.976}, {-1.000,  0.000}, {-0.992,  0.122}, {-0.405,  0.914},
	{-0.724, -0.690}, { 0.933,  0.360}, {-0.171, -0.985}, { 0.997,  0.074}, { 0.360, -0.933}, { 0.576, -0.818}, {-0.360,  0.933}, { 1.000,  0.025},
	{ 0.995,  0.098}, { 0.690, -0.724}, { 0.818, -0.576}, { 0.653,  0.757}, { 0.985, -0.171}, { 0.171,  0.985}, { 0.147,  0.989}, { 0.995, -0.098},
	{ 0.788, -0.615}, {-0.741, -0.672}, { 0.219,  0.976}, {-0.845, -0.535}, { 0.074,  0.997}, { 0.942, -0.337}, { 0.976, -0.219}, { 0.957, -0.290},
	{ 0.914, -0.405}, {-0.147,  0.989}, { 0.428,  0.904}, { 0.964, -0.267}, {-0.964, -0.267}, {-0.995, -0.098}, {-0.870, -0.493}, { 0.950,  0.314},
	{-0.741,  0.672}, { 0.360,  0.933}, { 0.514, -0.858}, { 0.970,  0.243}, {-0.653, -0.757}, {-0.707,  0.707}, { 0.405, -0.914}, {-0.989, -0.147},
	{ 0.904,  0.428}, {-0.556,  0.831}, { 0.493, -0.870}, {-0.450, -0.893}, { 0.219, -0.976}, {-0.933,  0.360}, { 0.025, -1.000}, {-0.757, -0.653},
	{ 0.428, -0.904}, {-0.243,  0.970}, { 0.914,  0.405}, {-0.219, -0.976}, { 0.634,  0.773}, {-0.981,  0.195}, { 0.049, -0.999}, {-0.314, -0.950},
	{ 0.845,  0.535}, {-0.707, -0.707}, { 0.803,  0.596}, { 0.290, -0.957}, { 0.882,  0.471}, {-0.025,  1.000}, {-0.858,  0.514}, { 0.634, -0.773},
	{ 0.290,  0.957}, {-0.950,  0.314}, { 0.267,  0.964}, { 1.000,  0.000}, { 0.450, -0.893}, {-0.957, -0.290}, {-0.290, -0.957}, {-0.337, -0.942},
	{-0.493, -0.870}, { 0.471,  0.882}, {-0.535, -0.845}, {-0.818,  0.576}, {-0.976,  0.219}, { 0.992, -0.122}, { 0.195,  0.981}, { 0.970, -0.243},
	{-0.882, -0.471}, {-0.976, -0.219}, { 0.707, -0.707}, {-0.074, -0.997}, {-0.493,  0.870}, {-0.576, -0.818}, {-0.788, -0.615}, { 0.831, -0.556}, 
};

const float WAVER_PERIOD = 0.33;

static inline cpVect
WaverForce(double seconds)
{
	double normalized = seconds/WAVER_PERIOD;
	
	double f = floor(normalized);
	unsigned long i = f;
	double t = normalized - f;
	
	return cpvlerp(WAVER[i&255], WAVER[(i+1)&255], t);
}

- (void)update:(Game *)game {
	if(health <= 0.0){
		pixelRect spriteRect = bodySprite.texRect;
		
		for(int i=0; i<3; i++){
			pixelRect rect = pixelRectMake(spriteRect.origin.x + rand()%(spriteRect.size.width - 2), spriteRect.origin.y + rand()%(spriteRect.size.height - 2), 2, 2);
			Sprite *gibSprite = [[Sprite alloc] initWithTexture:bodySprite.texture texRect:rect];
			
			ParticleCollection *gibs = [[ParticleCollection alloc] initWithCount:20 sprite:gibSprite physical:NO];
			[gibs setVelocityX:floatRangeMake(-200.0, 200.0) Y:floatRangeMake(50.0, 200.0)];
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x - 5, self.pixelPosition.x + 5) Y:floatRangeMake(self.pixelPosition.y - 5, self.pixelPosition.y - 5)];
			[gibs setLife:floatRangeMake(0.0, 0.3)];
			[game addItem:gibs];
		}
		
		[game removeItem:self];
		return;
	}
	
	Player *player = game.player;
	BOOL canSeePlayer = NO;
	if (player && cpvnear(player.position, self.position, 100)) {
		canSeePlayer = YES;
	}
	
	// express love if seeing player for the first time or 
	float distToPlayer = cpvdist(player.position, self.position);
	float probabilityOfLove = 1.0 - (distToPlayer - 10) / 100;
	probabilityOfLove *= 0.01;
	// NSLog(@"")
	if (canSeePlayer && (!seenPlayer || randomFloat(0.0, 1.0) < probabilityOfLove)) {
		seenPlayer = YES;
		// seeing player for the first time; express love
		ParticleCollection *p = [[ParticleCollection alloc] initWithCount:1 sprite:loveSprite physical:NO];
		[p setPositionX:floatRangeMake(self.position.x - 3, self.position.x + 3) Y:floatRangeMake(self.position.y + 5, self.position.y + 5)];
			// [p setVelocityX:floatRangeMake(0,0) Y:floatRangeMake(0,0)];
		[p setGravityX:floatRangeMake(0.0, 0.0) Y:floatRangeMake(180.0, 180.0)];
		[p setDamping:floatRangeMake(0.9, 0.95)];
		[p setLife:floatRangeMake(1.0, 1.0)];
		[game addItem:p];
	}
	
	// set target - chase player if near enough, else return home
	cpVect target = cpv(startingPosition.x, startingPosition.y);
	if (canSeePlayer) {
		target = player.position;
	}
	
	double seconds = game.fixedTime;
	double phase = self.objectPhase;
	
	cpVect target_force = cpvnormalize_safe(cpvsub(target, self.position));
	cpVect waver_force = WaverForce(seconds + phase*10.0);
	
	cpFloat pulse = cpfsin(seconds*8.0 + phase*2.0*M_PI)*0.5 + 0.5;
	cpVect motive_force = cpvmult(cpvadd(cpvmult(target_force, 50.0), cpvmult(waver_force, 40.0)), pulse);
	
	cpVect gravity_force = cpvmult(cpSpaceGetGravity(game.space), -cpBodyGetMass(body));
	cpBodySetForce(body, cpvadd(gravity_force, motive_force));
	
//	cpBodySetVel(body, cpvmult(cpBodyGetVel(body), cpfpow(0.1, FIXED_DT)));
}

- (void)addToSpace:(cpSpace *)space {
	cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
}

- (void)removeFromSpace:(cpSpace *)space {
	cpSpaceRemoveBody(space, body);
	cpSpaceRemoveShape(space, shape);
}

- (void)finalize {
	cpShapeFree(shape);
	cpBodyFree(body);
}

- (void)shotFrom:(cpVect)shotLocation damage:(float)damage;
{
	cpVect effect = cpvnormalize(cpvsub(cpBodyGetPos(body), shotLocation));
	effect = cpvmult(effect, 1000.0*damage);
	cpBodyApplyImpulse(body, effect, cpvzero);
	
	directionMask shotDirection = LEFT;
	if (shotLocation.x > self.position.x) shotDirection = RIGHT;
	
	pixelRect spriteRect = bodySprite.texRect;
	
	for(int i=0; i<3; i++){
		pixelRect rect = pixelRectMake(spriteRect.origin.x + rand()%(spriteRect.size.width - 2), spriteRect.origin.y + rand()%(spriteRect.size.height - 2), 2, 2);
		Sprite *gibSprite = [[Sprite alloc] initWithTexture:bodySprite.texture texRect:rect];
		
		ParticleCollection *gibs = [[ParticleCollection alloc] initWithCount:15 sprite:gibSprite physical:NO];
		if (shotDirection == LEFT) {
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x - 8, self.pixelPosition.x - 6) Y:floatRangeMake(self.pixelPosition.y - 3, self.pixelPosition.y + 3)];
			[gibs setVelocityX:floatRangeMake(-200.0, -100.0) Y:floatRangeMake(-30, 30)];
		}
		else {
			[gibs setPositionX:floatRangeMake(self.pixelPosition.x +6, self.pixelPosition.x + 8) Y:floatRangeMake(self.pixelPosition.y - 3, self.pixelPosition.y + 3)];
			[gibs setVelocityX:floatRangeMake(100.0, 200.0) Y:floatRangeMake(-30, 30)];
		}
		[gibs setLife:floatRangeMake(0.0, 0.3)];
		[[Game game] addItem:gibs];
	}
	
	health -= damage;
}

@end
