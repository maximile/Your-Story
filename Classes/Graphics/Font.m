#import "Font.h"
#import "Sprite.h"
#import "RandomTools.h"
#import "Constants.h"
#import "Texture.h"

@implementation Font

static NSMutableDictionary *fontsForNames;
static unichar spaceCharacter; 

+ (void)initialize {
	fontsForNames = [NSMutableDictionary dictionary];
	[@" " getCharacters:&spaceCharacter];
}

+ (Font *)fontNamed:(NSString *)name {
	Font * font = [fontsForNames objectForKey:name];
	if (font != nil) return font;
	
	NSString *fontPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
	NSDictionary *fontDict = [NSDictionary dictionaryWithContentsOfFile:fontPath];
	font = [[Font alloc] initWithDictionary:fontDict];
	
	if (font == nil) {
		NSLog(@"Nil font generated for name: %@", name);
		return nil;
	}
	
	[fontsForNames setObject:font forKey:name];
	return font;
}

- (id)initWithDictionary:(NSDictionary *)info {
	if ([self init]==nil) return nil;
	
	texture = [Texture textureNamed:[info valueForKey:@"Texture"]];
	NSString *characterString = [info valueForKey:@"Characters"];
	
	characterCount = characterString.length;
	characters = calloc(characterCount,sizeof(unichar));
	[characterString getCharacters:characters];
	
	// populate coordinates array and generate widths from sizes
	coords = calloc(characterCount,sizeof(pixelRect));
	widths = calloc(characterCount,sizeof(int));
	offsets = calloc(characterCount,sizeof(pixelCoords));
	
	NSArray *coordStrings = [info valueForKey:@"Coordinates"];
	if (coordStrings.count != characterCount) {
		NSLog(@"Should have %i sets of coordinates; %i found", characterCount, (int)coordStrings.count);
		return nil;
	}
	
	int index = 0;
	
	for (NSString *coordString in coordStrings) {
		coords[index] = pixelRectFromString(coordString);
		
		if (coords[index].size.height > maxHeight) maxHeight = coords[index].size.height;
		widths[index] = coords[index].size.width + 1;
		
		index++;
	}
	
	NSString *widthsString = [info valueForKey:@"Widths"];
	if (widthsString.length > 0) {
		widthsString = [widthsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *widthEntries = [widthsString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		index = -1;
		for (NSString *widthEntry in widthEntries) {
			index++;
			if (widthEntry.length == 0) continue;
			if (index >= characterCount) continue;
			if ([widthEntry stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length == widthEntry.length) continue;
			widths[index] = widthEntry.intValue;
		}
	}
	
	index = 0;
	for (NSString *offsetString in [info valueForKey:@"Offsets"]) {
		if (index >= characterCount) continue;
		pixelCoords offset = pixelCoordsFromString(offsetString);
		offsets[index] = offset;
		index++;
	}
	
	defaultSpacing = [[info valueForKey:@"Default Spacing"] intValue];
	
	NSNumber *spaceWidthValue = [info valueForKey:@"Space Width"];
	if (spaceWidthValue == nil) {
		spaceWidth = widths[(characterCount-1)/2] + defaultSpacing; // NOT ACTUALLY median width
	}
	else {
		spaceWidth = [spaceWidthValue intValue];
	}
	
	NSNumber *lineHeightValue = [info valueForKey:@"Line Height"];
	if (lineHeightValue == nil) {
		lineHeight = ceil(maxHeight * 1.2 + 1.0);
	}
	else {
		lineHeight = [lineHeightValue intValue];
	}
		
	return self;
}

- (int)indexForCharacter:(unichar)character {
	for (int i=0; i<characterCount; i++) {
		if (character == characters[i]) return i;
	}
	
	const float upperLowerOffset = 0x61 - 0x41;
	if (character >= 0x41 && character <= 0x5a) { // [A-Z]
		character += upperLowerOffset;
	}
	else if (character >= 0x61 && character <= 0x7a) { // [a-z]
		character -= upperLowerOffset;
	}
	
	for (int i=0; i<characterCount; i++) {
		if (character == characters[i]) return i;
	}
		
	return -1;
}

- (BOOL)indexIsValid:(int)index {
	if ((index >= 0) && (index < characterCount)) return YES;
	else return NO;
}

- (int)widthForString:(NSString *)string {
	int stringLength = [string length];
	unichar *stringCharacters = calloc(stringLength,sizeof(unichar));
	[string getCharacters:stringCharacters];
	
	int width = 0;
	for (int i=0; i<stringLength; i++) {
		unichar character = stringCharacters[i];
		if (character == spaceCharacter) {
			width += spaceWidth;
		}
		else {
			int characterIndex = [self indexForCharacter:character];
			if ([self indexIsValid:characterIndex]) {
				width += widths[characterIndex];
				width += defaultSpacing;
			}
		}
	}
	
	width -= defaultSpacing;
	free(stringCharacters);
	if (width < 0) width = 0;
	return width;
}

- (void)drawString:(NSString *)string at:(pixelCoords)loc alignment:(NSTextAlignment)alignment {
	int stringLength = [string length];
	unichar * stringCharacters = calloc(stringLength,sizeof(unichar));
	[string getCharacters:stringCharacters];
	
	pixelCoords cursor = loc;
	
	if (alignment==NSCenterTextAlignment) {
		cursor.x -= [self widthForString:string] / 2;
	}
	if (alignment==NSRightTextAlignment) {
		cursor.x -= [self widthForString:string];
	}
	
	for (int i=0; i<stringLength; i++) {
		if (stringCharacters[i] == spaceCharacter) {
			cursor.x += spaceWidth;
			continue;
		}
	
		int characterIndex = [self indexForCharacter:stringCharacters[i]];
		if ([self indexIsValid:characterIndex] == NO) {
			continue;
		}
		
		cursor.x += offsets[characterIndex].x;
		cursor.y += offsets[characterIndex].y;
		
		pixelRect drawRect = pixelRectMake(cursor.x, cursor.y, coords[characterIndex].size.width, coords[characterIndex].size.height);
		[texture addRect:drawRect texRect:coords[characterIndex]];
		
		cursor.x -= offsets[characterIndex].x;
		cursor.y -= offsets[characterIndex].y;
		
		cursor.x += widths[characterIndex];
		cursor.x += defaultSpacing;
	}
	
	free(stringCharacters);
}

- (void)finalize {
	free(characters);
	free(coords);
	free(widths);
	free(offsets);
		
	[super finalize];
}

@end
