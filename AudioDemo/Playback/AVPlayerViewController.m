//
//  AVPlayerViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerViewController ()

@end

@implementation AVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark AVPlayer
- (void)startMixPlay2 {
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    
    //AVPlayer
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path1]];
    player.volume = 1.0;
    
    //监听播放状态
    [player.currentItem addObserver:self forKeyPath:@"stauts" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //监听网络缓存加载进度
    [player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [player play];
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:player.currentItem];
    
    NSLog(@"status=%ld", player.status);
    //监听player播放进度
    [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        //do something
        NSLog(@"addPeriodicTimeObserverForInterval");
        //        //当前播放的时间
        //        float current = CMTimeGetSeconds(time);
        //        //总时间
        //        float total = CMTimeGetSeconds(item.duration);
        //        if (current) {
        //            float progress = current / total;
        //            //更新播放进度条
        //            weakSelf.playSlider.value = progress;
        //        }
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"未知转态");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"准备播放");
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"加载失败");
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray * timeRanges = change[NSKeyValueChangeNewKey];
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        //        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        //        //计算缓冲百分比例
        //        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲进度条
        //            self.loadTimeProgress.progress = scale;
    }
}


@end
