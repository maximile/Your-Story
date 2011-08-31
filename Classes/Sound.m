//
//  Sound.m
//  Your Story
//
//  Created by Scott Lembcke on 8/28/11.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import "Sound.h"

#import <OpenAL/alc.h>

#define OV_EXCLUDE_STATIC_CALLBACKS
#import "ogg/ogg.h"
#import "vorbis/vorbisfile.h"


static void
CheckALErrors()
{
	for(ALenum err; (err = alGetError());){
		NSLog(@"OpenAL error: 0x%x", err);
		[NSException raise:@"OpenALError" format:@"OpenAL error: 0x%x", err];
	}
}

@implementation Sound

#define NUM_CHANNELS 16

static NSMutableDictionary *sounds;
static ALuint channels[NUM_CHANNELS];

- (id)initWithFilename:(NSString *)filename
{
	if((self = [super init])){
		NSLog(@"Loading ogg file %@", filename);
		NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
		
		FILE *file = fopen([[url path] UTF8String], "rb");
		if(!file) [NSException raise:@"FileNotFound" format:@"Could not load ogg file %@.", filename];
		
		OggVorbis_File vorbis;
		if(ov_open(file, &vorbis, NULL, 0)){
			[NSException raise:@"OggError" format:@"Error reading ogg file %@", filename];
		}
		
		vorbis_info *info = ov_info(&vorbis, -1);
		int samples = ov_pcm_total(&vorbis, -1);
		int channels = info->channels;
		
		_rate = info->rate;
		_duration = (float)samples/(float)_rate;
		
		// Breaks for non mono/stereo
		_format = (channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
		int bytes = 2*samples*channels;
		
		void *sampleData = malloc(bytes);
		
		int bytes_read = 0;
		while(bytes_read < bytes){
			int remain = bytes - bytes_read;
			void *cursor = sampleData + bytes_read;
			
			long value = ov_read(&vorbis, cursor, remain, (BYTE_ORDER==BIG_ENDIAN), 2, 1, NULL);
			if(value < 0) [NSException raise:@"OggError" format:@"Error reading ogg file %@ at %d", filename, bytes_read];
			
			bytes_read += value;
		}
		
		alGenBuffers(1, &_buffer);
		alBufferData(_buffer, _format, sampleData, bytes, _rate);
		
		ov_clear(&vorbis);
		free(sampleData);
		fclose(file);
		CheckALErrors();
	}
	
	return self;
}

-(void)finalize
{
	// TODO safe to do here?
	alDeleteBuffers(1, &_buffer);
	
	[super finalize];
}

+(void)initialize
{
	sounds = [[NSMutableDictionary alloc] init];
	
	alGenSources(NUM_CHANNELS, channels);
	CheckALErrors();
}

static ALuint
GetOpenChannel()
{
	for(int i=0; i<NUM_CHANNELS; i++){
		ALint state;
		alGetSourcei(channels[i], AL_SOURCE_STATE, &state);
		
		if(state != AL_PLAYING){
			return channels[i];
		}
	}
	
	return 0;
}

+(void)playSound:(NSString *)filename volume:(float)volume pitch:(float)pitch;
{
	Sound *sound = [sounds objectForKey:filename];
	
	if(!sound){
		sound = [[Sound alloc] initWithFilename:filename];
		[sounds setObject:sound forKey:filename];
	}
	
	ALuint source = GetOpenChannel();
	
	if(source){
		alSourcei(source, AL_BUFFER, sound->_buffer);
		alSourcef(source, AL_GAIN, volume);
		alSourcef(source, AL_PITCH, pitch);
		alSourcePlay(source);
	}
	
	CheckALErrors();
}

+(void)playSound:(NSString *)filename;
{
	[self playSound:filename volume:1.0 pitch:1.0];
}

@end
