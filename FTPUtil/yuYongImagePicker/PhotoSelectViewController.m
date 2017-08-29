//
//  PhotoSelectViewController.m
//  shanmeng
//
//  Created by fcrj on 2017/8/3.
//  Copyright © 2017年 fancheng. All rights reserved.
//

#import "PhotoSelectViewController.h"
#import "WSImagePickerView.h"

@interface PhotoSelectViewController ()

@end

@implementation PhotoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
//    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
    /**
     * 关闭导航栏半透明 -> 向下偏移64问题
     */
    self.navigationController.navigationBar.translucent = NO;
    
    
    WSImagePickerConfig * config = [[WSImagePickerConfig alloc] init];
    config.itemSize = CGSizeMake(80, 80);
    config.photosMaxCount = 6;
    
    WSImagePickerView * pickView = [[WSImagePickerView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300) config:config];
    pickView.backgroundColor     = [UIColor cyanColor];
    
    pickView.navigationController = self.navigationController;
    
    [self.view addSubview:pickView];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
    
    btn.backgroundColor = [UIColor cyanColor];
    
    [btn addTarget:self action:@selector(actionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

- (void) actionAction{
    
    
    PhotoSelectViewController * photoVC = [[PhotoSelectViewController alloc] init];
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:photoVC];
    
    [self presentViewController:navi animated:YES completion:nil];
}

@end
