//
//  FirstViewController.m
//  MVVMReactiveCocoa
//
//  Created by zhoushuai on 16/8/10.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "MainViewController.h"
#import "VideoViewModel.h"
//这里测试登录界面后的一个界面，展示视频列表
@interface MainViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) VideoViewModel *videoViewModel;

@end

@implementation MainViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RAC&&MVVM";
    
    //设置UI
    [self setupUI];
    
    //设置绑定
    [self setupBind];
    
    //进入界面首次下拉刷新
    [self.tableView.mj_header beginRefreshing];
}

- (void)dealloc{
    //测试有没有循环引用...
}


#pragma mark - private Methods
- (void)setupUI{
    [self.view addSubview:self.tableView];
    @weakify(self)
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self.videoViewModel.requestVideoListCommand execute:@{@"headerRefresh":@"1"}];
    }];
    //下拉加载更多
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self.videoViewModel.requestVideoListCommand execute:@{@"headerRefresh":@"0"}];
    }];
}


- (void)setupBind{
    self.videoViewModel.currentVC = self;
    self.tableView.dataSource = self.videoViewModel;
    self.tableView.delegate = self.videoViewModel;
    
    //通知方法刷新表视图
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NotificationName_RefreshMainVC object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self resetRefreshView];
        [self.tableView reloadData];
     }];
}


- (void)resetRefreshView{
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
    }
}


#pragma mark - Getter && Setter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - 64);
        _tableView.estimatedRowHeight = 50.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (VideoViewModel *)videoViewModel{
    if (!_videoViewModel) {
        _videoViewModel = [[VideoViewModel alloc] init];
    }
    return _videoViewModel;
}

@end
