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

/**
 *    添加播放功能
 *    1.自定义一个管理文件格式、路径等信息的结构体
 *    2.定义一个音频队列函数去执行播放功能
 *    3.定义音频队列缓存区的大小
 *    4.open一个需要播放的音频文件，并且定义它的数据编码格式
 *    5.创建一个音频队列并且配置它
 *    6.为缓存区分配内存和入队列。启动音频队列播放，并在callback函数中适当时候结束它。
 *    7.销毁音频队列
 */

//自定义音频信息结构
static const int kNumberBuffers = 3;//单个缓冲区，一个填充数据，一个取数据，一个在磁盘I/O延迟补偿的时候用。
struct MyAudioInfo{
    AudioFileID mAudioFile;
    AudioStreamBasicDescription mDataFormat;//the audio data format of the file being play
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    
    UInt32 bufferByteSize;//single buffer size ,in bytes
    SInt64    mCurrentPacket;//packet index for the next packet to play from the audio file
    UInt32 mNumPacketsToRead;//callback 函数每次调用从文件中取出的packet数量
    AudioStreamPacketDescription *mPacketDescs;//音频数据是VBR，则是对一组将要播放的packet的描述。是    CBR，则为NULL
    bool    mIsRunning;//current audio queue is running
    
};
typedef struct MyAudioInfo MyAudioInfo;


@interface AudioQueueViewController (){
    MyAudioInfo myAudioInfo;
}

@end

@implementation AudioQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.backgroundColor = [UIColor blueColor];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

/** 回调方法
 *	1.从音频文件获取数据，填入缓冲区
 *	2.将填充后的缓冲区加入缓冲队列
 *	3.没有数据可读时，结束音频队列
 */
void HandlerOutputBuffer(void* inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer){
    
 	MyAudioInfo *myAudioInfo  = (MyAudioInfo *)inUserData;
    if (myAudioInfo -> mIsRunning == 0) return;
    
    //get data from file and put in buffer
    UInt32 ioNumBytes;
    UInt32 iosNumPackets = myAudioInfo -> mNumPacketsToRead;
    AudioFileReadPacketData(myAudioInfo -> mAudioFile,
                            false,
                            &ioNumBytes,
                            myAudioInfo -> mPacketDescs,
                            myAudioInfo -> mCurrentPacket,
                            &iosNumPackets,
                            inBuffer -> mAudioData);
    NSLog(@"HandlerOutputBuffer");
    //no data can read from the file
    if (iosNumPackets == 0) {
        AudioQueueStop(inAQ, false);//当缓冲队列中的缓冲数据都播放完后，同步结束音频队列
        myAudioInfo -> mIsRunning = false;
    }else{
        
        inBuffer -> mAudioDataByteSize = ioNumBytes;
        
        //add the buffer to buffer queue
        AudioQueueEnqueueBuffer(inAQ,
                                inBuffer,
                                myAudioInfo -> mPacketDescs ? iosNumPackets:0,//The number of packets represented in the audio queue buffer’s data. For CBR data, which uses no packet descriptions, uses 0.
                                myAudioInfo -> mPacketDescs);
        //update packet start index
        myAudioInfo -> mCurrentPacket += iosNumPackets;
    }
}

/** 设置缓存区大小，需要考虑数据格式，以及和格式先关的一些因素，比如采集通道数
 *	ASBDesc	aduio queue struct description
 *  maxPacketSize 预估文件packet的大小，可以通过AudioFileGetProperty来获取
 *  seconds 每个缓存区的音频时间长度
 *	outBufferSize 每个缓存区的字节大小
 *	outNumPacketsToRead 每次回调方法调用想要从文件获取packet的数量
 */
void DeriveBufferSize(AudioStreamBasicDescription ASBDesc,
                      UInt32 maxPacketSize,
                      Float64 seconds,
                      UInt32 *outBufferSize,
                      UInt32 *outNumPacketsToRead){
    
    static const int maxBufferSize = 0x50000;//320k
    static const int minBufferSize = 0x4000;//16k
    
    if (ASBDesc.mFramesPerPacket != 0) {//

        Float64 numPacketsForTime = ASBDesc.mSampleRate / ASBDesc.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    }else{//
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize:maxPacketSize;
    }
    
    if (*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize) {//
        *outBufferSize = maxBufferSize;
    }else{//
        if (*outBufferSize < minBufferSize) {
            *outBufferSize = minBufferSize;
        }
    }
    
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

bool getFilename(char* buffer,int maxBufferLength)
{
    NSString* file = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"wav"];
    return [file getCString:buffer maxLength:maxBufferLength encoding:NSUTF8StringEncoding];
}

- (void)play{
    
    if (myAudioInfo.mIsRunning) {
        [self stop];
        return;
    }
    
    //create CFURLRef
    char filePath[256];
    memset(filePath,0,sizeof(filePath));
    getFilename(filePath,256); //path的目录已经得到了
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8 *)filePath, strlen(filePath), false);
    
    //open auido file
    AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, 0, &myAudioInfo.mAudioFile);
    CFRelease(audioFileURL);
    
    
    //obtaining a file's Audio data format
    UInt32 dataFormatSize = sizeof(myAudioInfo.mDataFormat);
    
    AudioFileGetProperty(myAudioInfo.mAudioFile,
                         kAudioFilePropertyDataFormat,
                         &dataFormatSize,
                         &myAudioInfo.mDataFormat);
    
    //create Audio queue
    AudioQueueNewOutput(&myAudioInfo.mDataFormat,
                        HandlerOutputBuffer,
                        &myAudioInfo,
                        CFRunLoopGetCurrent(),
                        kCFRunLoopCommonModes,
                        0,
                        &myAudioInfo.mQueue);
    
    //Set Buffer Size and Number of Packets to Read
    UInt32 maxPacketSize;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(myAudioInfo.mAudioFile,
                         kAudioFilePropertyPacketSizeUpperBound,
                         &propertySize,
                         &maxPacketSize);
    
    DeriveBufferSize(myAudioInfo.mDataFormat,
                     maxPacketSize,
                     0.5,
                     &myAudioInfo.bufferByteSize,
                     &myAudioInfo.mNumPacketsToRead);
    
    //Allocate Memory for a Packet Descriptions Array
    bool isFormatVBR = ( myAudioInfo.mDataFormat.mFramesPerPacket == 0 || myAudioInfo.mDataFormat.mBytesPerFrame == 0 );
    if (isFormatVBR) {
        myAudioInfo.mPacketDescs = (AudioStreamPacketDescription*) malloc(myAudioInfo.mNumPacketsToRead * sizeof(AudioStreamPacketDescription));
    }else{
        myAudioInfo.mPacketDescs = NULL;
    }
    
    //Set a Magic Cookie for a Playback Audio Queue
    UInt32 cookieSize = sizeof(UInt32);
    bool canGetProperty = AudioFileGetPropertyInfo(myAudioInfo.mAudioFile,
                                                   kAudioFilePropertyMagicCookieData,
                                                   &cookieSize,
                                                   NULL);
    if (!canGetProperty && cookieSize) {
        char* magicCookie = (char *)malloc(cookieSize);
        
        AudioFileGetProperty(myAudioInfo.mAudioFile,
                             kAudioFilePropertyMagicCookieData,
                             &cookieSize,
                             magicCookie);
        
        AudioQueueSetProperty(myAudioInfo.mQueue,
                              kAudioQueueProperty_MagicCookie,
                              magicCookie,
                              cookieSize);
        
        free(magicCookie);
    }
    
    //Allocate and Prime Audio Queue Buffers
    myAudioInfo.mCurrentPacket = 0;
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer(myAudioInfo.mQueue, myAudioInfo.bufferByteSize, &myAudioInfo.mBuffers[i]);
        HandlerOutputBuffer(&myAudioInfo, myAudioInfo.mQueue, myAudioInfo.mBuffers[i]);
    }
    
    //Set an Audio Queue‘s Playback Gain
    Float32 gain = 1.0;
    AudioQueueSetParameter(myAudioInfo.mQueue, kAudioQueueParam_Volume, gain);
    
    
    //Start and Run an Audio Queue
    myAudioInfo.mIsRunning = true;
    AudioQueueStart(myAudioInfo.mQueue, NULL);
    
    do {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode,
                           0.25,
                           false);
    } while (myAudioInfo.mIsRunning);
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode,
                       1,
                       false);
}

- (void)stop{
    if (myAudioInfo.mIsRunning) {
        AudioQueueStop(myAudioInfo.mQueue, false);//当缓冲队列中的缓冲数据都播放完后，同步结束音频队列
        myAudioInfo.mIsRunning = false;
        
        [self cleanUpAfterPlay];
    }
}

//Clean up After Playing
- (void)cleanUpAfterPlay{
    AudioQueueDispose(myAudioInfo.mQueue, true);
    
    AudioFileClose(myAudioInfo.mAudioFile);
    
    free(myAudioInfo.mPacketDescs);
}

@end
