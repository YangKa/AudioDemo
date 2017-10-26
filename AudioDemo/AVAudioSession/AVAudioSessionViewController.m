//
//  AVAudioSessionViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AVAudioSessionViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVAudioSessionViewController ()

@end

@implementation AVAudioSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark -
#pragma mark handle audio interruption notification
- (void)handleInterruption:(NSNotification *)notification {
    
    UInt8 type = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
        //        [self stopPlayer];
        //        // tell the delegate to update UI
        //        if ([self.delegate respondsToSelector:@selector(engineWasInterrupted)]) {
        //            [self.delegate engineWasInterrupted];
        //        }
        
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        
        NSError *error;
        BOOL success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (!success)
            NSLog(@"AVAudioSession set active failed with error: %@", [error localizedDescription]);
    }
}

- (void)handleRouteChange:(NSNotification *)notification {
    
    UInt8 reason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *previousRoute = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    NSLog(@"Route change:");
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"CategoryChange");
            NSLog(@"New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"NoSuitableRouteForCategory");
            break;
        default:
            NSLog(@"Unknown");
    }
    
    NSLog(@"Previous route: %@", previousRoute);
    
    
}

- (void)handleMediaServicesReset:(NSNotification *)notification {
    NSLog(@"Media services have been reset! TODO: Re-wiring connections");
    //    [self setupAudioSession];
    //    [self setupEngine];
}

@end
