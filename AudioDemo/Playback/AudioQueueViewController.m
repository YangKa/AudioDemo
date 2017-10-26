//
//  AudioQueueViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/26.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AudioQueueViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#import <AVFoundation/AVFoundation.h>

@interface AudioQueueViewController (){
    AudioStreamBasicDescription _recordFormat;


    AudioQueueRef _audioQueue;
}

@end

@implementation AudioQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)play{
    
    AudioQueueNewOutput(&(_recordFormat), outputCallBack, (__bridge void*)self, NULL, NULL, 0, &(_audioQueue));
}

void outputCallBack(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer){
//    AudioFileOpenURL(CFURLRef  _Nonnull inFileRef, AudioFilePermissions inPermissions, AudioFileTypeID inFileTypeHint, AudioFileID  _Nullable * _Nonnull outAudioFile)
//    AudioFileReadPacketData(AudioFileID  _Nonnull inAudioFile, Boolean inUseCache, UInt32 * _Nonnull ioNumBytes, AudioStreamPacketDescription * _Nullable outPacketDescriptions, SInt64 inStartingPacket, UInt32 * _Nonnull ioNumPackets, void * _Nullable outBuffer)
}

@end
