//
//  MenuViewController.m
//  FTPUtil
//
//  Created by fcrj on 2017/8/15.
//  Copyright © 2017年 heshanwangluo. All rights reserved.
//

#import "MenuViewController.h"
#import "FileViewController.h"
#import "GRRequestsManager.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"

@interface MenuViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
GRRequestsManagerDelegate  
>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) GRRequestsManager * ftpManager;

@end

@implementation MenuViewController{

    /** 设置菜单 */
    NSArray * _menuArr;
    
    /** 上传之后从本地存储中删除图片 */
    NSString * _currentUploadImage;
}

-(GRRequestsManager *)ftpManager{
    
    if (_ftpManager == nil) {
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary * dic = [defaults objectForKey:@"WWAccount"];
        
        NSString * server = dic[@"server"];
        NSString * userName = dic[@"userName"];
        NSString * password = dic[@"password"];
        
        _ftpManager = [[GRRequestsManager alloc] initWithHostname:server user:userName password:password];
        _ftpManager.delegate = self;
    }
    return _ftpManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"FTP文件管理";
    _menuArr = @[@"查看文件",@"上传图片",@"设置1",@"设置2",@"设置3"];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
//    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"menuCell"];
    
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:self.tableView];
    
    
    /* 无法加载图片
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(200, 500, 100, 100)];
    img.backgroundColor = [UIColor greenColor];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"ftp://192.168.100.204/screen.png"]];
    img.image = [UIImage imageWithData:data];
    
    [self.view addSubview:img];
     */
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _menuArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
//    if () {
//        
//    }
    cell.textLabel.text = _menuArr[indexPath.row];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        FileViewController * fileVC = [[FileViewController alloc] init];
        [self.navigationController pushViewController:fileVC animated:YES];
    }else if (indexPath.row == 1){
        // 上传图片
        [self pickImage];
    }
}
#pragma mark - 选择图片按钮
- (void)pickImage{
    
    
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"选择要上传FTP的图片" preferredStyle:UIAlertControllerStyleActionSheet];
    //取消
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 选择拍照
        [self openCameraOrAlbum:1];
    }];
    UIAlertAction * picAction   = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraOrAlbum:2];
    }];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 支持相机
        [alertVC addAction:cancelAction];
        [alertVC addAction:cameraAction];
        [alertVC addAction:picAction];
    }else{// 不支持相机
        [alertVC addAction:picAction];
        [alertVC addAction:cancelAction];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
#pragma mark - 打开相机、相册 index 1：相机   2：相册
- (void) openCameraOrAlbum:(NSInteger)index{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; //隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
    NSInteger  sourceType = 0;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (index) {
            case 1:
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                // 相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
    }
    else {
        
        
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        
    }
    
    // 跳转到相机或相册页面
    /*
     [JFImagePickerController setMaxCount:10];
     JFImagePickerController * jfVC = [[JFImagePickerController alloc] initWithRootViewController:[UIViewController new]];
     jfVC.pickerDelegate = self;
     [self presentViewController:jfVC animated:YES completion:nil];
     */
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
    
    
}

#pragma mark - 选完图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; //隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    [picker dismissViewControllerAnimated:YES completion:^{}];
//      UIImagePickerControllerEditedImage
    UIImage *image1 = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSData *imageData = UIImageJPEGRepresentation(image1,0.1);
    NSString *strname = @"Documents/currentUpload.png";

    
    NSString *filePath1=[NSHomeDirectory() stringByAppendingPathComponent:strname];
    [imageData writeToFile:filePath1 atomically:YES];
    NSLog(@"%@",filePath1);
    _currentUploadImage = filePath1;
    [self.ftpManager addRequestForUploadFileAtLocalPath:filePath1 toRemotePath:@"dir/cc.png"];
    [self.ftpManager startProcessingRequests];
}

#pragma mark - upload回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request{

    [SVProgressHUD showInfoWithStatus:@"上传成功!"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_currentUploadImage error:nil];
}



@end
