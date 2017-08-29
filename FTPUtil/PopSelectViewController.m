//
//  PopSelectViewController.m
//  shanmeng
//
//  Created by fcrj on 2017/6/16.
//  Copyright © 2017年 fancheng. All rights reserved.
//

#import "PopSelectViewController.h"

@interface PopSelectViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end


static NSString * identifier = @"popCell";


@implementation PopSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
}

#pragma mark - 代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.itemArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
//    cell.textLabel.text = self.itemArr[indexPath.row][@"name"];
    cell.textLabel.text = self.itemArr[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
//    cell.textLabel.text = @"55555555";
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.popDelegate changeTextFiledContentWith:self.itemArr[indexPath.row]];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

@end
