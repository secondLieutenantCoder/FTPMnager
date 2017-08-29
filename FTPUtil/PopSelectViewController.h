//
//  PopSelectViewController.h
//  shanmeng
//
//  Created by fcrj on 2017/6/16.
//  Copyright © 2017年 fancheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeTextFiledProtocol <NSObject>

- (void) changeTextFiledContentWith:(NSString *)newContent;

@end

@interface PopSelectViewController : UIViewController

/** 弹窗控制器要显示的数据 */
@property (nonatomic,strong) NSArray * itemArr;

/** 代理 */
@property (nonatomic,weak) id<ChangeTextFiledProtocol>popDelegate;

@end

/*
    修改参数
    itemArr直接存放参数
    不再使用 name
 */
