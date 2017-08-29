//
//  checkString.h
//  慈善
//
//  Created by 凡城软件 on 16/3/31.
//  Copyright © 2016年 fancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface checkString : NSObject

// 检测数字
+ (BOOL)validateNumber:(NSString *) textString;
// 检测手机号
+ (BOOL)validatePhoneNumber:(NSString *) textString;
//  检测邮箱
+ (BOOL)validateEmail:(NSString *) textString;
//  检测义工编号
+ (BOOL)validateYGNo:(NSString *) textString;
//  检测身份证
+ (BOOL)validateCertNo:(NSString *) textString;

@end
