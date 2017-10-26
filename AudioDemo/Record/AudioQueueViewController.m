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
    int _sampleRate;
    int _bufferDurationSeconds;
    
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef *_audioBuffers;
}

@property BOOL isRecording;

@end

#define kNumberAudioQueueBuffers 3 //3个缓冲区
#define kDefaultBufferDurationSeconds 0.1279  //调整这个值使得录音的缓冲区大小为2048bytes
#define kDefaultSampleRate 8000 //采样率
@implementation AudioQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sampleRate =  kDefaultSampleRate;
    _bufferDurationSeconds = kDefaultBufferDurationSeconds;
    
    [self setupAudioFormat:kAudioFormatLinearPCM sampleRate:_sampleRate];
}

- (void)setupAudioFormat:(UInt32)inFormatID sampleRate:(int)sampleRate{
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    
    _recordFormat.mSampleRate =sampleRate;
    _recordFormat.mChannelsPerFrame = 1;
    _recordFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM) {
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
        _recordFormat.mBitsPerChannel = 16;
        _recordFormat.mFramesPerPacket = 1;
        _recordFormat.mBytesPerPacket = _recordFormat.mFramesPerPacket*(_recordFormat.mBitsPerChannel*_recordFormat.mChannelsPerFrame)/8;
    }
}

- (void)startRecording{
    NSError *error;
    if ([[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        NSLog(@"声音环境设置失败！");
    }else{
        if (error) {
            NSLog(@"error=%@", error);
        }
    }
    BOOL success =  [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (!success) NSLog(@"激活失败");
    
    _recordFormat.mSampleRate = _sampleRate;
    
    //初始化音频输出队列
    AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void*)self, NULL, NULL, 0, &_audioQueue);
    
    //估算缓存区的大小
    int frameCount = (int)ceil(_bufferDurationSeconds*_recordFormat.mSampleRate);
    int bufferByteSize = frameCount*_recordFormat.mBytesPerFrame;
    
    //创建缓冲器
    for (int i=0; i<kNumberAudioQueueBuffers; i++) {
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
    }
    
    //开始录音
    AudioQueueStart(_audioQueue, NULL);
 
    self.isRecording =  YES;
    
}

- (void)stopRecording{
    NSLog(@"停止录音");
    
    if (self.isRecording) {
        self.isRecording = NO;
        
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);//移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

//回调函数
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs)
{
    NSLog(@"回调函数");
    
     AudioQueueViewController *VC = (__bridge AudioQueueViewController*)inUserData;
    if (inNumberPacketDescriptions > 0) {
        
        NSLog(@"in the callback the current thread is %@\n",[NSThread currentThread]);
        //在这个函数你可以用录音录到得PCM数据：inBuffer，去进行处理了
        //
        
       // AudioQueueOfflineRender(inAQ, inStartTime, inBuffer, inNumberPacketDescriptions);
    }
    
    if (VC.isRecording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)save{
//    AudioFileOpenURL(CFURLRef  _Nonnull inFileRef, AudioFilePermissions inPermissions, AudioFileTypeID inFileTypeHint, AudioFileID  _Nullable * _Nonnull outAudioFile)
//    AudioFileWritePackets(AudioFileID  _Nonnull inAudioFile, Boolean inUseCache, UInt32 inNumBytes, const AudioStreamPacketDescription * _Nullable inPacketDescriptions, SInt64 inStartingPacket, UInt32 * _Nonnull ioNumPackets, const void * _Nonnull inBuffer)
}

@end
