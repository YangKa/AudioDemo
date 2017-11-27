//
//  AudioQueueViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/26.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AudioQueueRecordViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

/** 录音步骤
 * 1.自定义一个结构体，包含音频格式、保存路径等信息
 * 2.实现一个录音回调函数处理录音
 * 3.给音频队列缓存设置一个合适的大小。如果用刀use cookies，设置一下magic cookies。
 * 4.设置结构体其它信息，包括数据流格式、保存路径等
 * 5.创建一个音频队列，一个音频缓存队列，一个存放音频数据的文件。
 * 6.启动录音
 * 7.停止录音并销毁它。音频队列需要销毁缓存。
 */

static const int kNumberBuffers = 3;
struct MyRecordState {
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    AudioFileID mAudioFile;
    UInt32  bufferByteSize;
    SInt64  mCurrentPacket;
    AudioFileTypeID fileType;
    bool    mIsRunning;
};
typedef struct MyRecordState MyRecordState;

@interface AudioQueueRecordViewController (){
    MyRecordState _myRecord;
}


@end

@implementation AudioQueueRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//回调函数
static void HandleInputBuffer(void                  *aqData,
                              AudioQueueRef         inAQ,
                              AudioQueueBufferRef   inBuffer,
                              const AudioTimeStamp *inStartTime,
                              UInt32                inNumPackets,
                              const AudioStreamPacketDescription    *inPacketDesc){
    
    MyRecordState *myRecord = (MyRecordState*)aqData;
    
    if (inNumPackets == 0 && myRecord -> mDataFormat.mBytesPerPacket != 0)  {
        inNumPackets = inBuffer -> mAudioDataByteSize / myRecord -> mDataFormat.mBytesPerPacket;
    }
    
    OSStatus result = AudioFileWritePackets(myRecord -> mAudioFile,
                                          false,
                                          inBuffer -> mAudioDataByteSize,
                                          inPacketDesc,
                                          myRecord -> mCurrentPacket,
                                          &inNumPackets,
                                          inBuffer -> mAudioData);
    if ( result ) {
        myRecord -> mCurrentPacket += inNumPackets;
    }
    
    if (myRecord -> mIsRunning == 0) {
        return;
    }
    
    AudioQueueEnqueueBuffer(myRecord -> mQueue, inBuffer, 0, NULL);
    
}

//Derive Recording Audio Queue Buffer Size
void DeriveBufferSize (
                       AudioQueueRef                audioQueue,
                       AudioStreamBasicDescription  ASBDescription,
                       Float64                      seconds,
                       UInt32                       *outBufferSize
) {
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = ASBDescription.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (
                               audioQueue,
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               &maxPacketSize,
                               &maxVBRPacketSize
                               );
    }
    
    Float64 numBytesForTime =
    ASBDescription.mSampleRate * maxPacketSize * seconds;
    *outBufferSize = (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);
}

OSStatus SetMagicCookieForFile (AudioQueueRef inQueue, AudioFileID   inFile ) {
    OSStatus result = noErr;
    UInt32 cookieSize;
    
    if (AudioQueueGetPropertySize (inQueue,
                                   kAudioQueueProperty_MagicCookie,
                                   &cookieSize
                                   ) == noErr) {
        
        char* magicCookie =
        (char *) malloc (cookieSize);
        if (AudioQueueGetProperty (
                                   inQueue,
                                   kAudioQueueProperty_MagicCookie,
                                   magicCookie,
                                   &cookieSize
                                   ) == noErr)
            result =    AudioFileSetProperty (
                                              inFile,
                                              kAudioFilePropertyMagicCookieData,
                                              cookieSize,
                                              magicCookie
                                              );
        free (magicCookie);
    }
    return result;
}

- (void)setRecordFormat{
    
    _myRecord.mDataFormat.mFormatID         = kAudioFormatLinearPCM; // 2
    _myRecord.mDataFormat.mSampleRate       = 44100.0;               // 3
    _myRecord.mDataFormat.mChannelsPerFrame = 2;                     // 4
    _myRecord.mDataFormat.mBitsPerChannel   = 16;                    // 5
    _myRecord.mDataFormat.mBytesPerPacket   =                        // 6
    _myRecord.mDataFormat.mBytesPerFrame =
    _myRecord.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    _myRecord.mDataFormat.mFramesPerPacket  = 1;                     // 7
    
    _myRecord.fileType =  kAudioFileAIFFType;    // 8
    _myRecord.mDataFormat.mFormatFlags =  kLinearPCMFormatFlagIsBigEndian
                                            | kLinearPCMFormatFlagIsSignedInteger
                                            | kLinearPCMFormatFlagIsPacked;
}

- (void)createAudioFile{
    
    [self createAudioFile];
    
    char filePath[256];
    memset(filePath,0,sizeof(filePath));
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"1.wav"];
    [file getCString:filePath maxLength:256 encoding:NSUTF8StringEncoding];
    
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)filePath, strlen(filePath), false);
    
    AudioFileCreateWithURL(audioFileURL,
                           _myRecord.fileType,
                           &_myRecord.mDataFormat,
                           kAudioFileFlags_EraseFile,
                           &_myRecord.mAudioFile);
    
    DeriveBufferSize (
                      _myRecord.mQueue,
                      _myRecord.mDataFormat,
                      0.5,
                      &_myRecord.bufferByteSize
                      );
    
    
    for (int i = 0; i < kNumberBuffers; ++i) {           // 1
        AudioQueueAllocateBuffer (                       // 2
                                  _myRecord.mQueue,                               // 3
                                  _myRecord.bufferByteSize,                       // 4
                                  &_myRecord.mBuffers[i]                          // 5
                                  );
        
        AudioQueueEnqueueBuffer (                        // 6
                                 _myRecord.mQueue,                               // 7
                                 _myRecord.mBuffers[i],                          // 8
                                 0,                                           // 9
                                 NULL                                         // 10
                                 );
    }
    
    
    _myRecord.mCurrentPacket = 0;                           // 1
    _myRecord.mIsRunning = true;                            // 2
    AudioQueueStart (                                    // 3
                     _myRecord.mQueue,                                   // 4
                     NULL                                             // 5
                     );
}


@end
