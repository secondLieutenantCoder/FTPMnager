//
//  UUIDUtil.m
//  shanmeng
//
//  Created by fcrj on 2017/6/28.
//  Copyright © 2017年 fancheng. All rights reserved.
//

#import "UUIDUtil.h"

@implementation UUIDUtil


+(NSString *) getUUIDString{

    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    
    return uuid;
}

@end
