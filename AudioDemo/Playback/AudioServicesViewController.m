//
//  AudioToolViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/26.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AudioServicesViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface AudioServicesViewController ()

@end

@implementation AudioServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
        //do something
    });
}

//只能30s以内的铃声
- (void)playMusic{
    
    //alert sound
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
        //do something
    });
    
    //system sound
    SystemSoundID systemSound = kAudioServicesPropertyIsUISound;
    AudioServicesPlaySystemSoundWithCompletion(systemSound, ^{
       //do something
    });
    
    //remove
   // AudioServicesRemoveSystemSoundCompletion(systemSound);
}

@end
