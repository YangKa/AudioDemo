//
//  CoreAudioViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "CoreAudioViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CoreAudioViewController ()

@end

@implementation CoreAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)playAudio{
    //create audio file
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"4.caf"];
    NSURL *fileURL = [ NSURL fileURLWithPath:filePath];
    
    AudioStreamBasicDescription informat;
    AudioFileID audioFileID;
    AudioFileCreateWithURL(
                           (__bridge CFURLRef)fileURL,
                           kAudioFileCAFType,
                           &informat,
                           kAudioFileFlags_EraseFile,
                           &audioFileID
                           );
    
    
    //open audio file
    NSURL *fileURL1 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"wav"];
    
    AudioFileID audioFileID1;
    AudioFileOpenURL((__bridge CFURLRef)fileURL1,
                     kAudioFileReadPermission,
                     kAudioFileCAFType,
                     audioFileID1);
    
    
    
}


@end
