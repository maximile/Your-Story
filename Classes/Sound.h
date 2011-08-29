//
//  Sound.h
//  Your Story
//
//  Created by Scott Lembcke on 8/28/11.
//  Copyright 2011 Max Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenAL/al.h>

@interface Sound : NSObject {
@private
	ALenum _format;
	ALuint _buffer;
	unsigned long _rate;
	float _duration;
}

+(void)playSound:(NSString *)filename volume:(float)volume pitch:(float)pitch;
+(void)playSound:(NSString *)filename;

@end
