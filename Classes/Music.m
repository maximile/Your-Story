#import "Music.h"

#include <stdlib.h>
#include <string.h>

#import <OpenAL/alc.h>

@implementation Music

-(void)al_error:(int)line
{
	int error = alGetError();

	switch(error){
		case AL_INVALID_NAME:
			printf("AL: INVALID_NAME (%d)\n", line);
			break;
		case AL_INVALID_ENUM:
			printf("AL: INVALID_ENUM (%d)\n", line);
			break;
		case AL_INVALID_VALUE:
			printf("AL: INVALID_VALUE (%d)\n", line);
			break;
		case AL_INVALID_OPERATION:
			printf("AL: INVALID_OPERATION (%d)\n", line);
			break;
		case AL_OUT_OF_MEMORY:
			printf("AL: OUT_OF_MEMORY (%d)\n", line);
			break;
	}
}

static char*
ogg_error(int code)
{
	switch(code)
	{
		case OV_EREAD:
			return "Ogg: Read from media.";
		case OV_ENOTVORBIS:
			return "Ogg: Not Vorbis data.";
		case OV_EVERSION:
			return "Ogg: Vorbis version mismatch.";
		case OV_EBADHEADER:
			return "Ogg: Invalid Vorbis header.";
		case OV_EFAULT:
			return "Ogg: Internal logic fault (bug or heap/stack corruption.";
		default:
			return "Ogg: Unknown Ogg error.";
	}
}

static size_t
cb_read(void *ptr, size_t size, size_t nmemb, Music *self)
{
	int bytes = size*nmemb;
	int remain = [self->data length] - self->seek_offset - bytes;
	if(remain < 0) bytes += remain;
	
	memcpy(ptr, [self->data bytes] + self->seek_offset, bytes);
	self->seek_offset += bytes;
	
	
	return bytes;
}

static int
cb_seek(Music *self, ogg_int64_t offset, int whence)
{
	int seek_offset;
	
	switch(whence){
	case SEEK_CUR:
		seek_offset = self->seek_offset + offset;
		break;
	case SEEK_END:
		seek_offset = [self->data length] + offset;
		break;
	case SEEK_SET:
		seek_offset = offset;
		break;
	default:
		printf("Invalid whence enumerant\n");
		exit(1);
	}
	
	if(seek_offset > [self->data length]) return -1;
	
	self->seek_offset = seek_offset;
	return 0;	
}

static int
cb_close(Music *self)
{
	// TODO should this be ignored?
	NSLog(@"Ignored?");
//	free(self->data);
//	self->data = 0;
	return 0;
}

static long
cb_tell(Music *self)
{
	return self->seek_offset;
}


//static int
//isPlaying(Music *self)
-(bool)isPlaying
{
	ALenum state;
	alGetSourcei(self->source, AL_SOURCE_STATE, &state);
	
	return (state == AL_PLAYING);
}

//static int
//stream_stopped(Music *self)
-(bool)isStopped
{
	ALenum state;
	alGetSourcei(self->source, AL_SOURCE_STATE, &state);
	
	return (state == AL_STOPPED || state == AL_INITIAL);
}

//static int
//stream_paused(Music *self)
-(bool)isPaused
{
	ALenum state;
	alGetSourcei(self->source, AL_SOURCE_STATE, &state);
	
	return (state == AL_PAUSED);
}

//static int
//stream_read(Music *self, ALuint buffer)
-(bool)readInto:(ALuint)buffer
{
	char pcm[MUSIC_BUFFER_SIZE];
	int  size = 0;
	int  section;
	int  result;

	while(size < MUSIC_BUFFER_SIZE)
	{
		result = ov_read(&self->oggStream, pcm + size, MUSIC_BUFFER_SIZE - size,
			(BYTE_ORDER==BIG_ENDIAN), 2, 1, &section);
		
		if(result==0 && self->loop)
			ov_raw_seek(&self->oggStream, 0);
	
		if(result > 0)
			size += result;
		else
			if(result < 0){
				printf("Ogg error: %s\n", ogg_error(result));
			} else {
				break;
			}
	}
    
	if(size == 0){
		printf("stream end\n");
		return 0;
	}
  
	alBufferData(buffer, self->format, pcm, size, self->rate);
	[self al_error:__LINE__];
	
	return 1;
}

//static int
//stream_update(Music *self)
-(bool)updateStream
{
	int processed;
	int active = 1;

	alGetSourcei(self->source, AL_BUFFERS_PROCESSED, &processed);
	if(processed==MUSIC_BUFFERS)
		printf("All music buffers used up\n");
	
	
	while(processed--)
	{
		ALuint buffer;
		
		alSourceUnqueueBuffers(self->source, 1, &buffer);
		[self al_error:__LINE__];

		active = [self readInto:buffer];
		if(active)
			alSourceQueueBuffers(self->source, 1, &buffer);
	}

	[self al_error:__LINE__];

	return active;
}

//static void
//stream_empty(Music *self)
-(void)empty
{
	int queued;
	
	alGetSourcei(self->source, AL_BUFFERS_QUEUED, &queued);
	
	while(queued--)
	{
		ALuint buffer;

		alSourceUnqueueBuffers(self->source, 1, &buffer);
		[self al_error:__LINE__];
	}
}

//int
//timerCallback(int interval, Music *self)
-(void)timerCallback:(NSTimer*)theTimer
{
	// check/queue more buffers
	if(![self updateStream]){
		[theTimer invalidate];
		timer = nil;
	}
	
	if(![self isPlaying])
	{
		if(![self play])
			printf("Ogg abruptly stopped but was restarted.\n");
		else
			printf("Ogg stream was interrupted. Stopping music.\n");
		
	}
}


/*
 * API functions
 */

//int ogg_stream_play(Music *self)
-(bool)play
{
	if(![self isStopped]) return 1;
        
	int processed;
	alGetSourcei(self->source, AL_BUFFERS_PROCESSED, &processed);
	
	ALuint trash[processed];
	alSourceUnqueueBuffers(self->source, processed, trash);
	
	int num_buffers = MUSIC_BUFFERS;
	for(int i=0; i<MUSIC_BUFFERS; i++){
		if(![self readInto:buffers[i]]){
			num_buffers = i;
			break;
		}
	}
	
	alSourceQueueBuffers(self->source, num_buffers, self->buffers);
	alSourcePlay(self->source);
	
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:MUSIC_BUFFER_TIME target:self selector:@selector(timerCallback:) userInfo:nil repeats:TRUE];
    
	return 1;
}

//void ogg_stream_stop(Music *self)
-(void)stop
{
	if([self isStopped]) return;
	
	[timer invalidate];
	timer = nil;
	
	alSourceStop(self->source);
	
	ov_raw_seek(&self->oggStream, 0);
}

//void ogg_stream_pause(Music *self)
-(void)pause
{
	if(![self isPlaying]) return;
	
	alSourcePause(self->source);
	
	[timer invalidate];
	timer = nil;
}

//void ogg_stream_resume(Music *self)
-(void)resume
{
	if(![self isPaused]) return;
	
	[self updateStream];
	
	[timer invalidate];
	timer = [NSTimer timerWithTimeInterval:MUSIC_BUFFER_TIME target:self selector:@selector(timerCallback:) userInfo:nil repeats:TRUE];
	
	alSourcePlay(self->source);
	[self al_error:__LINE__];
}


-(id)initWithFilename:(NSString *)filename;
{
	if((self = [super init])){
		NSLog(@"Loading streamed ogg file %@", filename);
		NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
		
		data = [NSData dataWithContentsOfFile:[url path]];
		
		ov_callbacks cbacks = {
			.read_func = (void *)cb_read,
			.seek_func = (void *)cb_seek,
			.close_func = (void *)cb_close,
			.tell_func = (void *)cb_tell,
		};
		
		if(ov_open_callbacks(self, &self->oggStream, 0, 0, cbacks)){
			NSLog(@"ov_open_callbacks() failed %@\n", url);
//			NSLog(@"%s\n", ogg_error(err));
			exit(1);
		}
		
		vorbis_info *info = ov_info(&self->oggStream, -1);
		self->rate = info->rate;

		if(info->channels == 1)
				self->format = AL_FORMAT_MONO16;
		else
				self->format = AL_FORMAT_STEREO16;
				
				
		alGenBuffers(MUSIC_BUFFERS, self->buffers);
		[self al_error:__LINE__];
		alGenSources(1, &self->source);
		[self al_error:__LINE__];
		
		self->loop = TRUE;
			
//		alSource3f(self->source, AL_POSITION,        0.0, 0.0, 0.0);
//		alSource3f(self->source, AL_VELOCITY,        0.0, 0.0, 0.0);
//		alSource3f(self->source, AL_DIRECTION,       0.0, 0.0, 0.0);
//		alSourcef (self->source, AL_ROLLOFF_FACTOR,  0.0          );
//		alSourcei (self->source, AL_SOURCE_RELATIVE, AL_TRUE      );
	}

	return self;
}

- (void)dealloc
{
	if(alcGetCurrentContext()!=NULL){
		[self stop];
		[self empty];
		
		alDeleteSources(1, &self->source);
		[self al_error:__LINE__];
		alDeleteBuffers(MUSIC_BUFFERS, self->buffers);
		[self al_error:__LINE__];
	}

	ov_clear(&self->oggStream);
	
	[super dealloc];
}

@end
