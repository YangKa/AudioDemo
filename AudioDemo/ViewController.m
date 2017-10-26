//
//  ViewController.m
//  AudioDemo
//
//  Created by 杨卡 on 2017/10/25.
//  Copyright © 2017年 yangka. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_dataSourceList;
}

@end

@implementation ViewController

- (id)init{
    self = [super init];
    if (self) {
        _dataSourceList = @[@"MPMusicViewController",
                            @"AudioPlayerViewController",
                            @"AVPlayerViewController",
                            @"AVAudioEngineViewController",
                            @"AudioServicesViewController",
                            @"CoreAudioViewController",
                            @"AudioQueueViewController"
                            ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //AVAudioSession是所有播放和录音公共设置，建议监听Interruption通知
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self layoutUI];
}

- (void)layoutUI{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource  = self;
    [self.view addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0 ? @"play":@"record";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSourceList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section == 0) {
        cell.textLabel.text = _dataSourceList[indexPath.section];
    }else{
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSString *className = _dataSourceList[indexPath.section];
        Class class = NSClassFromString(className);
        UIViewController *vc = [[class alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
