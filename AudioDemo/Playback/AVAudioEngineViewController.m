//
//  AVAudioEngineViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AVAudioEngineViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVAudioEngineViewController (){
    AVAudioPlayerNode *playerNode;
    AVAudioEngine *engine;
}

@end

@implementation AVAudioEngineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark AVAudioEngine
/**
 * 特性：
 * AVAudioPlayer 进入后台自动停止播放，进入前台自动继续播放
 */
- (void)startMixPlay3{
    
    NSURL *pathURL = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp3"];
    NSError *error;
    AVAudioFile *file1 = [[AVAudioFile alloc] initForReading:pathURL error:&error];
    if (error) {
        NSLog(@"create audio file failed , error = %@", error);
    }else{
        engine = [[AVAudioEngine alloc] init];
        playerNode = [[AVAudioPlayerNode alloc] init];
        [engine attachNode:playerNode];
        [engine connect:playerNode to:engine.mainMixerNode format:file1.processingFormat];
        
        //only PCM
        AVAudioFormat *format1 = file1.processingFormat;
        AVAudioFrameCount count1 = (AVAudioFrameCount)file1.length;
        //PCM只支持采用PCM脉冲编码的格式，这是一种无压缩格式，比如wav是PCM编码的无压缩格式
        AVAudioPCMBuffer *buffer1 = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format1 frameCapacity:count1];
        [file1 readIntoBuffer:buffer1 error:nil];
        [playerNode scheduleBuffer:buffer1 atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        
        //prepare to play
        [engine startAndReturnError:nil];
        //play
        [playerNode play];
    }
}

- (void)startMixPlay4{
    
    NSURL *pathURL1 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"wav"];
    NSURL *pathURL2 = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp3"];
    NSURL *pathURL3 = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp3"];
    
    NSError *error;
    AVAudioFile *file1 = [[AVAudioFile alloc] initForReading:pathURL1 error:&error];
    AVAudioFile *file2 = [[AVAudioFile alloc] initForReading:pathURL2 error:&error];
    AVAudioFile *file3 = [[AVAudioFile alloc] initForReading:pathURL3 error:&error];
    if (error) {
        NSLog(@"create audio file failed , error = %@", error);
    }else{
        engine = [[AVAudioEngine alloc] init];
        playerNode = [[AVAudioPlayerNode alloc] init];
        [engine attachNode:playerNode];
        
        //速率、节距
        AVAudioUnitTimePitch *timePitchNode = [[AVAudioUnitTimePitch alloc] init];
        timePitchNode.pitch = 1.0f;//节距
        timePitchNode.rate = 2.0f;//速率
        [engine attachNode:timePitchNode];
        
        //回声
        AVAudioUnitDistortion *distortionNode = [[AVAudioUnitDistortion alloc] init];
        [distortionNode loadFactoryPreset:AVAudioUnitDistortionPresetMultiEcho1];
        [engine attachNode:distortionNode];
        
        //混响
        AVAudioUnitReverb *reverbNode = [[AVAudioUnitReverb alloc] init];
        [reverbNode loadFactoryPreset:AVAudioUnitReverbPresetCathedral];
        reverbNode.wetDryMix = 50;
        [engine attachNode:reverbNode];
        
        //connect node
        [engine connect:playerNode to:timePitchNode format:file1.processingFormat];
        [engine connect:timePitchNode to:distortionNode format:file1.processingFormat];
        [engine connect:distortionNode to:reverbNode format:file1.processingFormat];
        [engine connect:distortionNode to:engine.mainMixerNode format:file1.processingFormat];
        
        //没有unit变声处理
        // [engine connect:playerNode to:engine.mainMixerNode format:file1.processingFormat];
        
        //any format
        [playerNode scheduleFile:file1 atTime:nil  completionHandler:^{
            NSLog(@"scheduleFile file1");
        }];
        [playerNode scheduleFile:file2 atTime:nil  completionHandler:^{
            NSLog(@"scheduleFile file2");
        }];
        [playerNode scheduleFile:file3 atTime:nil  completionHandler:^{
            NSLog(@"scheduleFile file3");
        }];
        
        //prepare to play
        [engine startAndReturnError:nil];
        //play
        [playerNode play];
        
    }
}

//混音
- (void)startMixPlay5{
    
}

@end
