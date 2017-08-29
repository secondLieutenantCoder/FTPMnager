//
//  checkString.m
//  慈善
//
//  Created by 凡城软件 on 16/3/31.
//  Copyright © 2016年 fancheng. All rights reserved.
//

#import "checkString.h"

@implementation checkString
// 检测数字
+ (BOOL)validateNumber:(NSString *) textString
{
    NSString* number=@"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}
// 检测手机号
+ (BOOL)validatePhoneNumber:(NSString *) textString
{
    NSString* number=@"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}
//  检测邮箱
+ (BOOL)validateEmail:(NSString *) textString
{
    NSString* number= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}
+ (BOOL)validateYGNo:(NSString *) textString
{
    if (textString.length == 18) {
        return YES;
    }else{
        return NO;
    }
}
//  检测身份证
+ (BOOL)validateCertNo:(NSString *) textString{
    NSString* number=@"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}

@end
