//
//  AudioPlayerViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerViewController ()<AVAudioPlayerDelegate>

@end

@implementation AudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark AVAudioPlayer
- (void)startMixPlay1 {
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path1] error:&error];
    //建立代理
    audioPlayer.delegate = self;
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption) name:AVAudioSessionInterruptionNotification object:audioPlayer];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption) name:AVAudioSessionRouteChangeNotification object:audioPlayer];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption) name:AVAudioSessionMediaServicesWereLostNotification object:audioPlayer];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption) name:AVAudioSessionMediaServicesWereResetNotification object:audioPlayer];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:audioPlayer];
    
    [audioPlayer play];
    if (error) {
        NSLog(@"play start failed , error = %@", error);
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
}

@end
