#import "Texture.h"

NSString *InvalidImageError = @"InvalidImageError";
static NSMutableDictionary * texturesForNames;

@implementation Texture

+ (void)initialize {
	texturesForNames = [[NSMutableDictionary dictionaryWithCapacity:20] retain];
}

+ (Texture *)textureNamed:(NSString *)name {
	Texture * texture = [texturesForNames objectForKey:name];
	if (texture != nil) return texture;
	
	NSImage *image = [NSImage imageNamed:name];
	texture = [[Texture alloc] initWithImage:image];
	if (texture == nil) {NSLog(@"Nil texture generated for name: %@",name); return nil;}
	
	[texturesForNames setObject:texture forKey:name];
	return texture;
}

+ (Texture *)lightmapTexture {
	return [Texture textureNamed:@"light-point.psd"];
}

+ (NSArray *)lightmapTextures;
{
	static NSArray *lmTextures = nil;
	if (lmTextures == nil) {
		lmTextures = [NSArray arrayWithObjects:
			[Texture textureNamed:@"light-point.psd"],
			[Texture textureNamed:@"light-spread.psd"],
		 nil];
	}
	return lmTextures;
}

+ (NSArray *)textures {
	return texturesForNames.allValues;
}

- (void)finalize {
	// TODO finalize ran from a secondary thread
//	glDeleteTextures(1, &textureName);
	[super finalize];	
}


- (id)initWithImage:(NSImage *)image {
	if ([super init]==nil) return nil;
	
	NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	if (bitmap == nil) {
		[NSException raise:InvalidImageError format:@"Invalid image"];
	}

	// check image dimensions
	size = pixelSizeMake(bitmap.size.width, bitmap.size.height);
	if (size.width != size.height) {
		[NSException raise:InvalidImageError format:@"Image must be square"];
	}
	if (size.width < TILE_SIZE || size.height < TILE_SIZE) {
		[NSException raise:InvalidImageError format:@"Image must be larger than %ix%i", TILE_SIZE, TILE_SIZE];
	}
	if (size.width > 2048 || size.height > 2048) {
		[NSException raise:InvalidImageError format:@"Image must be no bigger than 2048x2048"];
	}
	// check that it's a power of two
	int test = 1;
	while (test <= 2048) {
		if (size.width == test) {
			// it's a power of two
			break;
		}
		test *= 2;
	}
	if (test > 2048) {
		[NSException raise:InvalidImageError format:@"Image dimensions must be a power of 2"];
	}
		
	// prepare image data
	unsigned short *data = calloc(size.width * size.height, sizeof(unsigned short));
	for (int y=0; y<size.height; y++) {
		for (int x=0; x<size.width; x++) {
			NSColor *pixelColor = [bitmap colorAtX:x y:y];
			// get 5 bit int for every component
			unsigned short red = round([pixelColor redComponent] * 31);
			unsigned short green = round([pixelColor greenComponent] * 31);
			unsigned short blue = round([pixelColor blueComponent] * 31);
			unsigned short alpha = round([pixelColor alphaComponent] * 1);
			// RRRRRGGGGGBBBBBA
			data[y*size.width+x] = (red << 11) | (green << 6) | (blue << 1) | (alpha);
		}
	}

	// assign to OpenGL texture
	GLint saveName;
	glGenTextures(1, &textureName);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
	glBindTexture(GL_TEXTURE_2D, saveName);
	
	free(data);
	return self;
}

- (void)addQuad:(pixelCoords *)quadCoords texCoords:(pixelCoords *)quadTexCoords {
	NSUInteger index = quadCount*12;
	
	// take an array of four coords and four tex coords
	if (quadCount >= slots) { // not enough space
		slots *= 2;
		if (slots == 0) slots = 1;
		size_t spaceSize = sizeof(GLfloat)*6*2*(slots);
		coords = realloc(coords, spaceSize);
		texCoords = realloc(texCoords, spaceSize);
	}
	
	coords[index+0]  = (float)quadCoords[0].x;
	coords[index+1]  = (float)quadCoords[0].y;
	coords[index+2]  = (float)quadCoords[1].x;
	coords[index+3]  = (float)quadCoords[1].y;
	coords[index+4]  = (float)quadCoords[2].x;
	coords[index+5]  = (float)quadCoords[2].y;
	coords[index+6]  = (float)quadCoords[2].x;
	coords[index+7]  = (float)quadCoords[2].y;
	coords[index+8]  = (float)quadCoords[1].x;
	coords[index+9]  = (float)quadCoords[1].y;
	coords[index+10] = (float)quadCoords[3].x;
	coords[index+11] = (float)quadCoords[3].y;

	texCoords[index+0]  = (float)quadTexCoords[0].x / size.width;
	texCoords[index+1]  = (float)quadTexCoords[0].y / size.height;
	texCoords[index+2]  = (float)quadTexCoords[1].x / size.width;
	texCoords[index+3]  = (float)quadTexCoords[1].y / size.height;
	texCoords[index+4]  = (float)quadTexCoords[2].x / size.width;
	texCoords[index+5]  = (float)quadTexCoords[2].y / size.height;
	texCoords[index+6]  = (float)quadTexCoords[2].x / size.width;
	texCoords[index+7]  = (float)quadTexCoords[2].y / size.height;
	texCoords[index+8]  = (float)quadTexCoords[1].x / size.width;
	texCoords[index+9]  = (float)quadTexCoords[1].y / size.height;
	texCoords[index+10] = (float)quadTexCoords[3].x / size.width;
	texCoords[index+11] = (float)quadTexCoords[3].y / size.height;
	
	quadCount++;
}

- (void)addRect:(pixelRect)rect texRect:(pixelRect)texRect {
	pixelCoords quadCoords[4];
	pixelCoords quadTexCoords[4];
	
	quadCoords[0] = pixelCoordsMake(rect.origin.x, rect.origin.y + rect.size.height);
	quadCoords[1] = pixelCoordsMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	quadCoords[2] = pixelCoordsMake(rect.origin.x, rect.origin.y);
	quadCoords[3] = pixelCoordsMake(rect.origin.x + rect.size.width, rect.origin.y);
	
	quadTexCoords[0] = pixelCoordsMake(texRect.origin.x, texRect.origin.y);
	quadTexCoords[1] = pixelCoordsMake(texRect.origin.x + texRect.size.width, texRect.origin.y);
	quadTexCoords[2] = pixelCoordsMake(texRect.origin.x, texRect.origin.y + texRect.size.height);
	quadTexCoords[3] = pixelCoordsMake(texRect.origin.x + texRect.size.width, texRect.origin.y + texRect.size.height);
	
	[self addQuad:quadCoords texCoords:quadTexCoords];
}

-(void)addAt:(pixelCoords)pos radius:(int)radius;
{
	pixelCoords quadCoords[4];
	pixelCoords quadTexCoords[4];
	
	quadCoords[0] = pixelCoordsMake(pos.x - radius, pos.y + radius);
	quadCoords[1] = pixelCoordsMake(pos.x + radius, pos.y + radius);
	quadCoords[2] = pixelCoordsMake(pos.x - radius, pos.y - radius);
	quadCoords[3] = pixelCoordsMake(pos.x + radius, pos.y - radius);
	
	int w = size.width;
	int h = size.height;
	quadTexCoords[0] = pixelCoordsMake(0, 0);
	quadTexCoords[1] = pixelCoordsMake(w, 0);
	quadTexCoords[2] = pixelCoordsMake(0, h);
	quadTexCoords[3] = pixelCoordsMake(w, h);
	
	[self addQuad:quadCoords texCoords:quadTexCoords];
}

- (void)draw {
	if (quadCount == 0) return;
		
	glBindTexture(GL_TEXTURE_2D, textureName);
	glVertexPointer(2, GL_FLOAT, 0, coords);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_TRIANGLES, 0, quadCount * 6);
		
	quadCount = 0;
}


@end
