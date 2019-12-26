//
//  STGameMusicPlayer.m
//  Start
//
//  Created by calvin on 2017/5/30.
//  Copyright © 2017年 DingSNS. All rights reserved.
//
#import "PSGameMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface PSGameMusicPlayer ()

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong, readonly) NSMutableDictionary *completionBlocks;
@property (nonatomic, assign) float volume;

@end

@implementation PSGameMusicPlayer

+ (PSGameMusicPlayer *)defaultPlayer {
    static PSGameMusicPlayer *musicPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        musicPlayer = [[self alloc] init];
    });
    return musicPlayer;
}

- (id)init {
    self = [super init];
    if (self) {
        _completionBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setMute:(BOOL)mute {
    _mute = mute;
    if (mute) {
        _volume = _player.volume;
        _player.volume = 0.f;
    }else{
        _player.volume = _volume;
    }
}

#pragma mark - SystemSoundID to or from data
- (NSData *)dataWithSoundID:(SystemSoundID)soundID {
    return [NSData dataWithBytes:&soundID length:sizeof(SystemSoundID)];
}

- (SystemSoundID)soundIDFromData:(NSData *)data {
    if (data) {
        SystemSoundID soundID;
        [data getBytes:&soundID length:sizeof(SystemSoundID)];
        return soundID;
    }else{
        return 0;
    }
}

#pragma mark - block
- (GameSoundPlayerCompletionBlock)completionBlockForSoundID:(SystemSoundID)soundID {
    NSData *data = [self dataWithSoundID:soundID];
    return [self.completionBlocks objectForKey:data];
}

- (void)addCompletionBlock:(GameSoundPlayerCompletionBlock)block
                 toSoundID:(SystemSoundID)soundID {
    NSData *data = [self dataWithSoundID:soundID];
    [self.completionBlocks setObject:block forKey:data];
}

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID {
    NSData *key = [self dataWithSoundID:soundID];
    [self.completionBlocks removeObjectForKey:key];
    AudioServicesRemoveSystemSoundCompletion(soundID);
}

- (SystemSoundID)createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)extension {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        SystemSoundID soundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
        if (error) {
            return 0;
        }
        else {
            return soundID;
        }
    }
    return 0;
}

- (void)playSoundWithFilename:(NSString *_Nullable)filename
                fileExtension:(NSString *_Nullable)fileExtension
                   completion:(nullable GameSoundPlayerCompletionBlock)completionBlock{
    if (_mute) {
        return;
    }
    SystemSoundID soundID = [self createSoundIDWithName:filename extension:fileExtension];
    if (soundID) {
        OSStatus error = AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, GameSoundCompleteCallback, NULL);
        if (error == kAudioServicesNoError) {
            [self addCompletionBlock:completionBlock toSoundID:soundID];
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

void GameSoundCompleteCallback(SystemSoundID soundID,void * clientData){
    AudioServicesDisposeSystemSoundID(soundID);
    PSGameMusicPlayer *player = [PSGameMusicPlayer defaultPlayer];
    GameSoundPlayerCompletionBlock block = [player completionBlockForSoundID:soundID];
    if (block) {
        block();
        [player removeCompletionBlockForSoundID:soundID];
    }
}

- (void)playBackgroundMusicWithFilename:(NSString *_Nullable)filename
                          fileExtension:(NSString *_Nullable)fileExtension
                          numberOfLoops:(NSInteger)number {
    if ([_player isPlaying]) {
        [_player stop];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:fileExtension];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error = nil;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
        _volume = _player.volume;
        if (!error) {
            [_player setNumberOfLoops:number];
            [_player setVolume:_mute ? 0 : _volume];
            [_player prepareToPlay];
            [_player play];
        }
    }else{
        //PSLog(@"音频文件不存在");
    }
}

- (void)playBackgroundMusicWithFilename:(NSString *)filename fileExtension:(NSString *)fileExtension {
    [self playBackgroundMusicWithFilename:filename fileExtension:fileExtension numberOfLoops:0];
}

- (void)stopBackgroundMusic {
    if ([_player isPlaying]) {
        [_player stop];
    }
    _player = nil;
}

@end
