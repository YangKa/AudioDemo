//
//  AVAudioRecorderViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/26.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AVAudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVAudioRecorderViewController ()<AVAudioRecorderDelegate>

@end

@implementation AVAudioRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)startRecording{
    
    
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.wav"];
    NSURL *saveURL = [NSURL fileURLWithPath:path];
    NSDictionary *setting = @{AVSampleRateKey:@8000,
                              AVNumberOfChannelsKey:@1,
                              AVFormatIDKey:[NSNumber numberWithInteger:kAudioFormatLinearPCM],
                              AVLinearPCMBitDepthKey:@16
                              };
    
    NSError *error;
    AVAudioRecorder *audioRecorder = [[AVAudioRecorder alloc] initWithURL:saveURL settings:setting error:&error];
    if (error) {
        NSLog(@"error=%@", error);
    }
    audioRecorder.delegate = self;
    [audioRecorder recordForDuration:30];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
}


#pragma mark AVAudioRecordDelegate
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    [recorder stop];
    [recorder deleteRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [recorder stop];
    
    NSURL *newFileURL;
    NSURL *fileURL = recorder.url;
    if ([[NSFileManager defaultManager] isExecutableFileAtPath:fileURL.absoluteString]) {
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newFileURL error:nil];
    }
}

- (void)interruption:(NSNotification*)notification{
    AVAudioSessionInterruptionType type = (AVAudioSessionInterruptionType)[notification valueForKey:AVAudioSessionInterruptionTypeKey];
    
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:{
            
        }break;
        case AVAudioSessionInterruptionTypeEnded:{
            
        }break;
    }
}

@end
