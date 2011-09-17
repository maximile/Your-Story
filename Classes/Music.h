#import <Foundation/Foundation.h>

#import <OpenAL/al.h>

#define OV_EXCLUDE_STATIC_CALLBACKS
#import "ogg/ogg.h"
#import "vorbis/vorbisfile.h"

#define MUSIC_BUFFERS 4
#define MUSIC_BUFFER_SIZE (128*1024)
#define MUSIC_BUFFER_TIME 0.1

@interface Music : NSObject {
@private
	NSData *data;
	int seek_offset;
	
	OggVorbis_File oggStream;
	
	ALuint rate;
	ALuint buffers[MUSIC_BUFFERS];
	ALuint source;
	ALenum format;
	
	int open;
	int loop;
	NSTimer *timer;
}

-(id)initWithFilename:(NSString *)filename;
-(bool)play;
-(void)stop;
-(void)pause;
-(void)resume;

@end
