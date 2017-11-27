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



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //AVAudioSession是所有播放和录音公共设置，建议监听Interruption通知
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    _dataSourceList = @[@"MPMusicViewController",
                        @"AudioPlayerViewController",
                        @"AVPlayerViewController",
                        @"AVAudioEngineViewController",
                        @"AudioServicesViewController",
                        @"AudioQueueViewController"
                        ];
    
    [self layoutUI];
}

static void extracted(ViewController *object) {
    UITableView *tableView = [[UITableView alloc] initWithFrame:object.view.bounds];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate = object;
    tableView.dataSource  = object;
    [object.view addSubview:tableView];
}

- (void)layoutUI{
    extracted(self);
    
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
        cell.textLabel.text = _dataSourceList[indexPath.row];
    }else{
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSString *className = _dataSourceList[indexPath.row];
        Class class = NSClassFromString(className);
        UIViewController *vc = [[class alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder { 
    <#code#>
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
    <#code#>
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    <#code#>
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
    <#code#>
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    <#code#>
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    <#code#>
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    <#code#>
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
    <#code#>
}

- (void)setNeedsFocusUpdate { 
    <#code#>
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context { 
    <#code#>
}

- (void)updateFocusIfNeeded { 
    <#code#>
}

