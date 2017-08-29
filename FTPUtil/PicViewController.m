//
//  PicViewController.m
//  FTPUtil
//
//  Created by fcrj on 2017/8/18.
//  Copyright © 2017年 heshanwangluo. All rights reserved.
//

#import "PicViewController.h"

@interface PicViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.image = [UIImage imageWithContentsOfFile:self.localImageStr];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
