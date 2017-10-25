//
//  MPMusicViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "MPMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MPMusicViewController ()<MPMediaPickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation MPMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark 播放手机音乐库中的音乐
- (void)startMixPlay{
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.allowsPickingMultipleItems = YES;
    // mediaPicker.prompt = @"显示在导航栏之上，会导致导航栏下移";
    mediaPicker.delegate = self;
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    
    MPMediaItem *item = [mediaItemCollection.items firstObject];
    NSString *title = item.title;
    MPMediaItemArtwork *artwork = [item valueForKey:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:CGSizeMake(100, 100)];
    NSLog(@"title=%@,  image=%@", title, image);
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
    musicPlayer.repeatMode = MPMusicRepeatModeAll;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
    
    [musicPlayer setQueueWithItemCollection:mediaItemCollection];
    //[musicPlayer setQueueWithQuery:MPMediaQuery.songsQuery];
    
    [musicPlayer play];
    
    //对MPMusicPlayerController无效
    //[self remoteControlEventHandler];
}

- (void)playStateChange:(NSNotification*)notification{
    MPMusicPlayerController *musicPlayer = notification.object;
    switch (musicPlayer.playbackState) {
        case MPMusicPlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMusicPlaybackStatePaused:
            NSLog(@"播放暂停.");
            break;
        case MPMusicPlaybackStateStopped:
            NSLog(@"播放停止.");
            break;
            //以下没有触发，暂无怎么监听上一曲和下一曲动作的思路
        case MPMusicPlaybackStateInterrupted:
            NSLog(@"播放打断.");
            break;
        case MPMusicPlaybackStateSeekingForward:
            NSLog(@"播放下一曲");
            break;
        case MPMusicPlaybackStateSeekingBackward:
            NSLog(@"播放上一曲");
            break;
    }
}

#pragma mark 锁屏信息显示
- (void)updateScreenPalyInfoWithMediaItem:(MPMediaItem*)item{
    //每次切换播放源时调用更新
    //    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(100, 100) requestHandler:^UIImage * _Nonnull(CGSize size) {
    //        return [UIImage imageNamed:@"music"];
    //    }];
    
    NSDictionary *info = @{
                           MPMediaItemPropertyTitle :item.title,
                           MPMediaItemPropertyArtist :item.artist,
                           MPMediaItemPropertyPlaybackDuration :[NSNumber numberWithInteger:item.playbackDuration],//歌曲时间长度
                           MPMediaItemPropertyArtwork : [item valueForKey:MPMediaItemPropertyArtwork],//@"封面图片"
                           MPNowPlayingInfoPropertyElapsedPlaybackTime : @0,//已播放时间长度
                           MPNowPlayingInfoPropertyPlaybackRate:@1
                           };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
    
}

#pragma mark 耳机或锁屏界面控制
- (void)remoteControlEventHandler{
    
    //直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTarget:self action:@selector(playAction:)];
    
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    // 为暂停, 上一曲, 下一曲分别添加对应的响应事件
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAction:)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackAction:)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackAction:)];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPauseAction:)];
}

-(void)playAction:(id)obj{
    NSLog(@"playAction");
}

-(void)pauseAction:(id)obj{
    NSLog(@"pauseAction");
}

-(void)nextTrackAction:(id)obj{
    NSLog(@"nextTrackAction");
}

-(void)previousTrackAction:(id)obj{
    NSLog(@"previousTrackAction");
}

-(void)playOrPauseAction:(id)obj{
    NSLog(@"playOrPauseAction");
}

@end
