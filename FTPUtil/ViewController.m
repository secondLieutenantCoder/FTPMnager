//
//  ViewController.m
//  FTPUtil
//
//  Created by fcrj on 2017/8/14.
//  Copyright © 2017年 heshanwangluo. All rights reserved.
//

#import "ViewController.h"

#import "GRRequestsManager.h"



@interface ViewController ()
<GRRequestsManagerDelegate>

/** ftp管理 */
@property (nonatomic,strong) GRRequestsManager * ftpManager;

@end

@implementation ViewController{

    UIButton * _btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ftpManager = [[GRRequestsManager alloc] initWithHostname:@"ftp://192.168.100.204/" user:@"ftp" password:@"123456"];
    
    self.ftpManager.delegate = self;
 
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 64, 80, 35)];
    _btn = btn;
    btn.backgroundColor = [UIColor redColor];
    
    [btn setTitle:@"获取列表" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(listing) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

#pragma mark - 获取列表
- (void) listing{

//     manager 获取FTP列表
    [self.ftpManager addRequestForListDirectoryAtPath:@"/"];
    [self.ftpManager startProcessingRequests];
}

#pragma mark - listing回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing{

    NSLog(@"%s,%@",__func__,listing);
    
    // unicode 转 utf8
    NSString * str = [self encodeToPercentEscapeString:[listing lastObject]];
    
    NSString * str1 = [[listing lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_btn setTitle:[listing lastObject] forState:UIControlStateNormal];
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input

{
    
    // Encode all the reserved characters, per RFC 3986
    
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    
//    NSString *outputStr = (NSString *)
//    
//    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                            
//                                            (CFStringRef)input,
//                                            
//                                            NULL,
//                                            
//                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                            
//                                            kCFStringEncodingUTF8);
    
    NSString * outputStr = [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet controlCharacterSet]];
    
    return outputStr;  
    
}




@end
