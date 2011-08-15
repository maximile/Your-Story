#import "Texture.h"

NSString *InvalidImageError = @"InvalidImageError";

@implementation Texture


- (void)finalize {
	glDeleteTextures(1, &textureName);
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

- (void)addRect:(pixelRect)rect texRect:(pixelRect)texRect {
	NSUInteger index = drawCount*12;
	
	GLfloat texCoordsLeft = texRect.origin.x / (float)size.width;
	GLfloat texCoordsRight = (texRect.origin.x + texRect.size.width) / (float)size.width;
	GLfloat texCoordsTop = texRect.origin.y / (float)size.height;
	GLfloat texCoordsBottom = (texRect.origin.y + texRect.size.height) / (float)size.height;
		
	if (drawCount >= slots) { // not enough space
		slots *= 2;
		if (slots == 0) slots = 1;
		size_t spaceSize = sizeof(GLfloat)*6*2*(slots);
		coords = realloc(coords, spaceSize);
		texCoords = realloc(texCoords, spaceSize);
	}
			
	coords[index+0]  = rect.origin.x;
	coords[index+1]  = rect.origin.y + rect.size.height;
	coords[index+2]  = rect.origin.x + rect.size.width;
	coords[index+3]  = rect.origin.y + rect.size.height;
	coords[index+4]  = rect.origin.x;
	coords[index+5]  = rect.origin.y;
	coords[index+6]  = rect.origin.x + rect.size.width;
	coords[index+7]  = rect.origin.y + rect.size.height;
	coords[index+8]  = rect.origin.x;
	coords[index+9]  = rect.origin.y;
	coords[index+10] = rect.origin.x + rect.size.width;
	coords[index+11] = rect.origin.y;

	texCoords[index+0]  = texCoordsLeft;
	texCoords[index+1]  = texCoordsTop;
	texCoords[index+2]  = texCoordsRight;
	texCoords[index+3]  = texCoordsTop;
	texCoords[index+4]  = texCoordsLeft;
	texCoords[index+5]  = texCoordsBottom;
	texCoords[index+6]  = texCoordsRight;
	texCoords[index+7]  = texCoordsTop;
	texCoords[index+8]  = texCoordsLeft;
	texCoords[index+9]  = texCoordsBottom;
	texCoords[index+10] = texCoordsRight;
	texCoords[index+11] = texCoordsBottom;
	
	drawCount++;
}

- (void)drawRects {
	if (drawCount == 0) return;
		
	glBindTexture(GL_TEXTURE_2D, textureName);
	glVertexPointer(2, GL_FLOAT, 0, coords);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_TRIANGLES, 0, drawCount * 6);
		
	drawCount = 0;
}


@end
