//
//  ConnectFTPController.m
//  FTPUtil
//
//  Created by fcrj on 2017/8/15.
//  Copyright © 2017年 heshanwangluo. All rights reserved.
//

#import "ConnectFTPController.h"
#import "GRRequestsManager.h"
#import "SVProgressHUD.h"
#import "MenuViewController.h"
#import "FileViewController.h"


@interface ConnectFTPController ()<GRRequestsManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *port;

/** ftp 管理工具 */
@property (nonatomic,strong) GRRequestsManager * ftpManager;

@end

@implementation ConnectFTPController

//-(GRRequestsManager *)ftpManager{
//
//    if (_ftpManager == nil) {
//        
//    }
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
    
    self.connectBtn.layer.cornerRadius = 6.0;
    self.connectBtn.layer.borderWidth  = 0.3;
    
    // 通知 使能按钮
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abledReabledBtn) name:@"REABLEDBTN" object:nil];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * accountDic = [defaults objectForKey:@"WWAccount"];
    if (accountDic) {
        NSString * server   = accountDic[@"server"];
        NSString * userName = accountDic[@"userName"];
        NSString * passord  = accountDic[@"password"];
        
        self.address.text   = server;
        self.userName.text  = userName;
        self.password.text  = passord;
    }
    
}
- (IBAction)connectAction:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if (self.address.text.length <= 6) {
        [SVProgressHUD showInfoWithStatus:@"请填写FTP地址"];
    }else if (self.userName.text.length == 0){
        [SVProgressHUD showInfoWithStatus:@"请填写FTP用户名"];
    }else if(self.password.text.length == 0 ){
        [SVProgressHUD showInfoWithStatus:@"请填写FTP密码"];
    }else{
        
        [SVProgressHUD showProgress:-1 status:@"正在连接服务器"];
        //都已经填写信息
        NSString * hostStr;
        if ([self.address.text hasPrefix:@"ftp://"]) {
            hostStr = self.address.text;
        }else{
            hostStr = [NSString stringWithFormat:@"ftp://%@",self.address];
        }
        
        self.ftpManager = [[GRRequestsManager alloc] initWithHostname:hostStr user:self.userName.text password:self.password.text];
        self.ftpManager.delegate = self;
        
        [self.ftpManager addRequestForListDirectoryAtPath:@"/"];
        [self.ftpManager startProcessingRequests];
    }
}

#pragma mark - 重新使能按钮
- (void) abledReabledBtn{

    self.connectBtn.enabled = YES;
    
    [SVProgressHUD dismiss];
}

#pragma mark - 获取文件列表的结果
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing{

    NSLog(@"%@",listing);
    
    [SVProgressHUD dismiss];
    NSDictionary * accountDic = @{
                                  @"server":self.address.text,
                                  @"userName":self.userName.text,
                                  @"password":self.password.text
                                  };
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accountDic forKey:@"WWAccount"];
    
//    MenuViewController * menuVC = [[MenuViewController alloc] init];
    FileViewController * fileVC = [[FileViewController alloc] init];
    
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [UIApplication sharedApplication].delegate.window.rootViewController = navi;
    
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error{

    
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didStartRequest:(id<GRRequestProtocol>)request{

    
}
#pragma mark - dealloc移除通知
-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REABLEDBTN" object:nil];
}



@end
