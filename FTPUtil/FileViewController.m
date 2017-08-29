//
//  FileViewController.m
//  FTPUtil
//
//  Created by fcrj on 2017/8/15.
//  Copyright © 2017年 heshanwangluo. All rights reserved.
//

#import "FileViewController.h"
#import "GRRequestsManager.h"
#import "SVProgressHUD.h"
#import "ConnectFTPController.h"
#import "PopSelectViewController.h"
#import "PicViewController.h"
#import "checkString.h"
#import "UUIDUtil.h"
#import "WSImagePickerView.h"
#import "JFImagePickerController.h"

@interface FileViewController ()<
UITableViewDelegate,
UITableViewDataSource,
GRRequestsManagerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
ChangeTextFiledProtocol,
UIPopoverPresentationControllerDelegate
>

/** ftp 文件管理 */
@property (nonatomic,strong) GRRequestsManager * ftpManager;
/**  */
@property (nonatomic,strong) UITableView * tableView;

/** 设置选项 */
@property (nonatomic,strong) UIView * menuView;

/** 选择要上传图片的文件夹 */
@property (nonatomic,strong) UITableView * picTableView;

/** 蒙版btn */
@property (nonatomic,strong) UIButton * coverBtn;
/** 要上传的图片 */
@property (nonatomic) UIImageView * uploadImage;

/** 图片名称 */
@property (nonatomic,strong) UITextField * picNameTF;

/** 设置菜单 */
@property (nonatomic,strong) UIViewController * popVC;

/** 确定上传图片按钮 */
@property (nonatomic,strong) UIButton * uploadBtn;


@end

@implementation FileViewController{

    /** 文件 */
    NSMutableArray * _fileDirectoryArr;
    /** 文件类型 */
    NSMutableArray * _fileTypeArr;
    
    /** 选中图片的路径 */
    NSString * _currentUploadImage;
    /** 文件夹数组 */
    NSMutableArray * _dirArr;
    /** 要删除的文件的位置 */
    NSIndexPath * _deleteIndexPath;
    
    /** 刷新路径 */
    NSString * _refreshPah;
    
    /** 新建文件夹 的个数  */
    NSInteger   _newDirCount;
    /** 新建的人的文件的路径 */
    NSString * _personPath;
    
    /** 入党的五个阶段的文件夹 */
    NSArray * _fiveStageArr;
    
    /** 五个阶段之下的文件创建 index */
    NSInteger   _lastLyerIndex;
    
    NSMutableArray<UIImage *> *_photosArray;
    
    /** 上传图片 index */
    NSInteger _uploadIndex;
}
#pragma mark - 蒙版
-(UIButton *)coverBtn{

    if (_coverBtn == nil) {
        _coverBtn = [[UIButton alloc] initWithFrame:self.view.bounds];
        _coverBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_coverBtn addTarget:self action:@selector(coverAction:) forControlEvents:UIControlEventTouchUpInside];
        _coverBtn.hidden = YES;
        [self.view addSubview:_coverBtn];
    }
    return _coverBtn;
}
// 显示要上传的图片
-(UIImageView *)uploadImage{

    if (_uploadImage == nil) {
        _uploadImage = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-180)/2.0, 75, 180, 180)];
        _uploadImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_uploadImage];
        
    }
    return _uploadImage;
}
// 上传的图片名称
-(UITextField *)picNameTF{

    if (_picNameTF == nil) {
        _picNameTF = [[UITextField alloc] initWithFrame:CGRectMake(50, 260, WIDTH-100, 30)];
        _picNameTF.placeholder = @"  填写图片名称（无后缀）";
        _picNameTF.hidden = YES;
        _picNameTF.backgroundColor = [UIColor whiteColor];
        _picNameTF.layer.cornerRadius = 10;
//        [self.view addSubview:_picNameTF];
    }
    return _picNameTF;
}

// 确认上传按钮
-(UIButton *)uploadBtn {

    if (_uploadBtn == nil) {
        _uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, WIDTH-100, 30)];
        [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        _uploadBtn.layer.cornerRadius = 15;
        _uploadBtn.backgroundColor = [UIColor whiteColor];
        [_uploadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_uploadBtn addTarget:self action:@selector(sureUploadAcion:) forControlEvents:UIControlEventTouchUpInside];
        _uploadBtn.hidden = YES;
        [self.view addSubview:_uploadBtn];
    }
    return _uploadBtn;
}
#pragma armk - tableView选择要上传图片的文件夹
-(UITableView *)picTableView{

    if (_picTableView == nil) {
        _picTableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 190, WIDTH-100, HEIGHT-380)];
        _picTableView.delegate = self;
        _picTableView.dataSource = self;
        [_picTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"uploadPicCell"];
    }
    return _picTableView;
}

#pragma mark - 右上角设置菜单
-(UIView *)menuView{

    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH-100, 64, 80, 105)];
        _menuView.backgroundColor = [UIColor redColor];
        _menuView.hidden = YES;
        [self.view addSubview:_menuView];
        
        // 选择图片上传
        UIButton * picBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 80, 30)];
        picBtn.backgroundColor = [UIColor greenColor];
        [picBtn setTitle:@"上传图片" forState:UIControlStateNormal];
        [picBtn addTarget:self action:@selector(uploadPicAction) forControlEvents:UIControlEventTouchUpInside];
        [_menuView   addSubview:picBtn];
    }
    return _menuView;
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
    
    // 设置导航栏
    [self setNav];
    
    _newDirCount = 0;
    _lastLyerIndex = 0;
    _uploadIndex = 1;
    
    //> 初始化数组
    _fileDirectoryArr = [[NSMutableArray alloc] init];
    _fileTypeArr      = [[NSMutableArray alloc] init];
    
    _photosArray = [[NSMutableArray alloc] init];
    // > tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fileCell"];
    
    [self.view addSubview:self.tableView];
    /// 确定本控制器的路径目录
    if (self.ftpPath) {
        /// 子目录
        [self.ftpManager addRequestForListDirectoryAtPath:[NSString stringWithFormat:@"/%@/",self.ftpPath]];
        _refreshPah = [NSString stringWithFormat:@"/%@/",self.ftpPath];
    }else{
        /// 根目录
    [self.ftpManager addRequestForListDirectoryAtPath:@"/"];
        _refreshPah = @"/";
    }
    
    NSLog(@"*********************_refresh=%@",_refreshPah);
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"WWcreateDirectory"];
    [self.ftpManager startProcessingRequests];
    
    [SVProgressHUD showProgress:-1 status:@"正在获取数据"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    /// 判断 左边图标
    if (self.navigationController.topViewController == [self.navigationController.viewControllers firstObject]) {
        // 当前是根控制器
            UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            leftBtn.frame = CGRectMake(0, 0, 65, 30);
//            [leftBtn setBackgroundImage:[UIImage imageNamed:@"backw"] forState:UIControlStateNormal];
        [leftBtn setTitle:@"重新连接" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }else{
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backw"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    }
    
    
    
    
}

-(void) setNav{

    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    self.title = @"文件";
    
    NSInteger fileLayer = [self.navigationController.viewControllers indexOfObject:self];
    NSLog(@"==================%ld",fileLayer);
    /// 判断导航右上角 功能
    switch (fileLayer) {
        case 0:
            // 根控制器 无   村菜单
            break;
        case 1:{
            // 人 菜单
            UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            rightBtn.frame = CGRectMake(0, 0, 60, 30);
//            [rightBtn setBackgroundImage:[UIImage imageNamed:@"菜单"] forState:UIControlStateNormal];
            [rightBtn setTitle:@"新建" forState:UIControlStateNormal];
            rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [rightBtn addTarget:self action:@selector(createDirectory) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
            
            _fiveStageArr = @[@"1.申请入党",@"2.入党积极分子的确定和培养教育",@"3.发展对象的确定和考察",@"4.预备党员的接收",@"5.预备党员的教育、考察和转正"];
        }
        case 2:{
        
            // 人 菜单
            
        }
            break;
        case 3:{
            // 人的五个阶段菜单   无
            
        }
            break;
            
        case 4:{
        
            // 文件菜单  上传图片
            UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            rightBtn.frame = CGRectMake(0, 0, 60, 30);
//            [rightBtn setBackgroundImage:[UIImage imageNamed:@"菜单"] forState:UIControlStateNormal];
            rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [rightBtn setTitle:@"上传图片" forState:UIControlStateNormal];
            [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [rightBtn addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - 右上角设置按钮
- (void) rightAction{

//    self.menuView.hidden = NO;
    self.coverBtn.hidden = NO;
//    [self.view addSubview:self.menuView];
    self.menuView.hidden = NO;
    
}
#pragma mark - 返回
- (void) backAction{

    if (self.navigationController.topViewController == [self.navigationController.viewControllers firstObject]) {
        // 当前是根控制器
        [UIApplication sharedApplication].delegate.window.rootViewController = [[ConnectFTPController alloc] init];
        
//        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/",documentsDirectoryPath] error:nil];
        NSString *extension = @"png";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        NSEnumerator *enumerator = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [enumerator nextObject])) {
            if ([[filename pathExtension] isEqualToString:extension]) {
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:nil];
            }  
        } 
    }else{
    
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - 获取到FTP目录回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing{
    
    [SVProgressHUD dismiss];
    // > 清空
    [_fileDirectoryArr removeAllObjects];
    [_fileTypeArr removeAllObjects];
    // > 添加新目录下的数据 文件名和数据
    for (NSDictionary * dic in listing) {
        NSString * name = dic[@"name"];
        NSNumber * type = dic[@"type"];
        
        [_fileDirectoryArr addObject:name];
        [_fileTypeArr addObject:type];
    }
    
    if (listing.count == 2) {
        [SVProgressHUD showInfoWithStatus:@"空的文件夹"];
    }else{
//        _fileDirectoryArr = [[NSMutableArray alloc] initWithArray:listing];
        if ([_fileDirectoryArr containsObject:@"."] || [_fileDirectoryArr containsObject:@"."]) {
            [_fileDirectoryArr removeObject:@"."];
            [_fileDirectoryArr removeObject:@".."];
            
            [_fileTypeArr removeObjectAtIndex:0];
            [_fileTypeArr removeObjectAtIndex:0];
        }
        [self.tableView reloadData];
    }
    
    
    for (int i = 0;i<_fileTypeArr.count;i++) {
        
        NSNumber * fileType = _fileTypeArr[i];
        if ([fileType integerValue] == 8) {
            
            // 下载 图片
            
            NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            //    NSString * s = @"新建文件夹2/无后缀.png";
            
            NSString * filePath;
            if (self.ftpPath) {
                filePath = [self.ftpPath stringByAppendingString:_fileDirectoryArr[i]];
                filePath = [filePath substringFromIndex:1];
            }else{
                filePath = _fileDirectoryArr[i];
            }
            
            NSString *localFilePath = [documentsDirectoryPath stringByAppendingPathComponent:_fileDirectoryArr[i]];
            // 管理器下载文件到本地
            
//            if (self.ftpPath) {
//                filePath = [self.ftpPath stringByAppendingString:_fileDirectoryArr[i]];
//                filePath = [filePath substringFromIndex:1];
//            }else{
//                filePath = _fileDirectoryArr[i];
//            }
            [self.ftpManager addRequestForDownloadFileAtRemotePath:filePath toLocalPath:localFilePath];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"WWcreateDirectory"];
            [self.ftpManager startProcessingRequests];
        }
    }
    
    
}

- (NSString *)encodeString:(NSString *)string;
{
    NSString *urlEncoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                 NULL,
                                                                                                 (__bridge CFStringRef) string,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'/\"();:@&=+$,?%#[]% ",
                                                                                                 kCFStringEncodingUTF8);
    return urlEncoded;
}
#pragma mark  下载成功回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request{

    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *localFilePath = [documentsDirectoryPath stringByAppendingPathComponent:@"DownloadedFile.png"];
    NSLog(@"%@",localFilePath);
//    self.tableView.backgroundColor = [UIColor redColor];
    // 显示图片
    
}

#pragma mark  删除文件成功回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDeleteRequest:(id<GRRequestProtocol>)request{

    [SVProgressHUD dismiss];
        [_fileDirectoryArr removeObjectAtIndex:_deleteIndexPath.row];
        [_fileTypeArr removeObjectAtIndex:_deleteIndexPath.row];
    
        [self.tableView deleteRowsAtIndexPaths:@[_deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView reloadData];
}
#pragma mark 创建文件夹成功回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request{

    _newDirCount++ ;
    if (_newDirCount > 0 && _newDirCount<=5) {
    // 创建人文件夹成功
        // 循环创建子文件夹
            NSString * newName = _fiveStageArr[_newDirCount-1];
        
            [self createChildDirectroyWithNewName:newName];

    }
        if (_newDirCount >= 6) {
            /// 五个阶段创建完成
//            _newDirCount = 0;
            NSString * path = [[NSBundle mainBundle] pathForResource:@"LastLayer" ofType:@"plist"];
            NSArray * lastLayerArr = [NSArray arrayWithContentsOfFile:path];
            // > 第一个阶段的子文件
//            _lastLyerIndex++;
            if (_lastLyerIndex<4) {// 第一阶段
                NSString * stage = _fiveStageArr[0];
                NSString * last  = lastLayerArr[_lastLyerIndex];
                
                NSString * lastLayerPath = [_personPath stringByAppendingString:[NSString stringWithFormat:@"%@/",stage]];
                
                [self createChildDirectroyWithPath:lastLayerPath andNewName:last];
                _lastLyerIndex++;
//                NSLog(@"*****************%ld",_lastLyerIndex);
//                NSLog(@"%@",_personPath);
            }else if (_lastLyerIndex<13){ // 第二阶段
            NSString * stage = _fiveStageArr[1];
                NSString * last  = lastLayerArr[_lastLyerIndex];
                
                NSString * lastLayerPath = [_personPath stringByAppendingString:[NSString stringWithFormat:@"%@/",stage]];
                
                [self createChildDirectroyWithPath:lastLayerPath andNewName:last];
                _lastLyerIndex++;
            }else if (_lastLyerIndex<32){ // 第三阶段
            NSString * stage = _fiveStageArr[2];
                NSString * last  = lastLayerArr[_lastLyerIndex];
                
                NSString * lastLayerPath = [_personPath stringByAppendingString:[NSString stringWithFormat:@"%@/",stage]];
                
                [self createChildDirectroyWithPath:lastLayerPath andNewName:last];
                _lastLyerIndex++;
            }else if (_lastLyerIndex<50){ // 第四阶段
            NSString * stage = _fiveStageArr[3];
                NSString * last  = lastLayerArr[_lastLyerIndex];
                
                NSString * lastLayerPath = [_personPath stringByAppendingString:[NSString stringWithFormat:@"%@/",stage]];
                
                [self createChildDirectroyWithPath:lastLayerPath andNewName:last];
                _lastLyerIndex++;
            }else if(_lastLyerIndex<65){                        // 第五阶段
            NSString * stage = _fiveStageArr[4];
                NSString * last  = lastLayerArr[_lastLyerIndex];
                
                NSString * lastLayerPath = [_personPath stringByAppendingString:[NSString stringWithFormat:@"%@/",stage]];
                
                [self createChildDirectroyWithPath:lastLayerPath andNewName:last];
                _lastLyerIndex++;
                
            }else{
            // 创建完成
                _lastLyerIndex = 0;
                _newDirCount= 0;
                // 刷新当前页列表
                [self.ftpManager addRequestForListDirectoryAtPath:_refreshPah];
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                
                NSLog(@"refresh:%@================selfFtpPath%@",_refreshPah,self.ftpPath);
                [defaults removeObjectForKey:@"WWcreateDirectory"];
                [self.ftpManager startProcessingRequests];
                [SVProgressHUD showProgress:-1 status:@""];
            }
            
            
            
            
            
            
            
        
        
    }
    
}
#pragma mark - 创建子文件夹
- (void) createChildDirectroyWithPath:(NSString *)lastLyerPath andNewName:(NSString *)name{
    
    /**
     * 新建文件夹的处理
     */
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"createDirectory" forKey:@"WWcreateDirectory"];
    
    NSString * encodeCreatePath = [self createEncodeString:lastLyerPath];
    
    [defaults setObject:encodeCreatePath forKey:@"WWencodeCreatePath"];
    
    
    
    [self.ftpManager addRequestForCreateDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",lastLyerPath,name]];
    [self.ftpManager startProcessingRequests];
}

#pragma mark - 创建子文件夹
- (void) createChildDirectroyWithNewName:(NSString *)name{

    /**
     * 新建文件夹的处理
     */
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"createDirectory" forKey:@"WWcreateDirectory"];
    
    NSString * encodeCreatePath = [self createEncodeString:_personPath];
    
    [defaults setObject:encodeCreatePath forKey:@"WWencodeCreatePath"];
    
    
    
    [self.ftpManager addRequestForCreateDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",_personPath,name]];
    [self.ftpManager startProcessingRequests];
}

#pragma mark - tableview代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.tableView]) {
        return _fileDirectoryArr.count;
    }else if ([tableView isEqual:self.picTableView]){
        return _dirArr.count;
    }else{
    
        return 0;
    }
    
}


#pragma mark  cell设置
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([tableView isEqual:self.tableView]) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
        if ([_fileTypeArr[indexPath.row] integerValue] == 8) {
            // 文件
            cell.imageView.image = [UIImage imageNamed:@"文件"];
        }else if ([_fileTypeArr[indexPath.row] integerValue] == 4){
            // 文件夹
            cell.imageView.image = [UIImage imageNamed:@"文件夹"];
        }
        cell.textLabel.text    = _fileDirectoryArr[indexPath.row];
        // 省略中间部分 ...
//        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
//        cell.textLabel.minimumScaleFactor = 10;
        return cell;
    }else if([tableView isEqual:self.picTableView]){
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"uploadPicCell"];
        cell.imageView.image = [UIImage imageNamed:@"文件夹"];
        cell.textLabel.text  = _dirArr[indexPath.row];
        return cell;
    }else{
    
        return nil;
    }
    
}
#pragma mark  cell点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.tableView]) {
    
        if ([_fileTypeArr[indexPath.row] integerValue] == 8) {// 文件
//            [SVProgressHUD showInfoWithStatus:@"侧滑操作文件"];
//            if (_dirArr[indexPath.row]) {
//                <#statements#>
//            }
            NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString * filePath;
            if (self.ftpPath) {
                filePath = [self.ftpPath stringByAppendingString:_fileDirectoryArr[indexPath.row]];
                filePath = [filePath substringFromIndex:1];
            }else{
                filePath = _fileDirectoryArr[indexPath.row];
            }
//            s = [s substringFromIndex:1];
            
            NSString *localFilePath = [documentsDirectoryPath stringByAppendingPathComponent:_fileDirectoryArr[indexPath.row]];
            
            
            PicViewController * picVC = [[PicViewController alloc] init];
            picVC.localImageStr = localFilePath;
            
            [self.navigationController pushViewController:picVC animated:YES];
            
//            UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
//            view.backgroundColor = [UIColor greenColor];
//            [self.view addSubview:view];
//            view.image = [UIImage imageWithContentsOfFile:localFilePath];
            
        }else if([_fileTypeArr[indexPath.row] integerValue] == 4){// 文件夹
            
            NSString * fileStr = _fileDirectoryArr[indexPath.row];
            
            //        [self.ftpManager addRequestForListDirectoryAtPath:[NSString stringWithFormat:@"/%@/",fileStr]];
            //        [self.ftpManager startProcessingRequests];
            NSString * nextPath;
            if (self.ftpPath) {
                // 有值（子目录）
                nextPath = [NSString stringWithFormat:@"/%@/%@/",self.ftpPath,fileStr];
                
            }else{
                nextPath = [NSString stringWithFormat:@"/%@/",fileStr];
            }
            
            FileViewController * nextFileVC = [[FileViewController alloc] init];
            nextFileVC.ftpPath = nextPath;
            [self.navigationController pushViewController:nextFileVC animated:YES];
           
        }
    }else if ([tableView isEqual:self.picTableView]){
        /// 选择上传到哪一个文件夹
        if (self.picNameTF.text.length == 0 ) {
            [SVProgressHUD showInfoWithStatus:@"请填写图片名称"];
        }else if ([self.picNameTF.text containsString:@"."]){
        
            [SVProgressHUD showInfoWithStatus:@"图片名不能包含后缀"];
        }else{
        
            NSString * uploadPath = @"diretory/ccww.png";
            if (self.ftpPath) {
                uploadPath = [self.ftpPath stringByAppendingString:[NSString stringWithFormat:@"%@/%@.png",_dirArr[indexPath.row],self.picNameTF.text]];
            }else{
                uploadPath = [NSString stringWithFormat:@"%@/%@.png",_dirArr[indexPath.row],self.picNameTF.text];
            }
            
            [self.ftpManager addRequestForUploadFileAtLocalPath:_currentUploadImage toRemotePath:uploadPath];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"WWcreateDirectory"];
            [self.ftpManager startProcessingRequests];
        }
        
    }
    
    
}
- (void) sureUploadAcion{

//    /// 选择上传到哪一个文件夹
//    if (self.picNameTF.text.length == 0 ) {
//        [SVProgressHUD showInfoWithStatus:@"请填写图片名称"];
//    }else if ([self.picNameTF.text containsString:@"."]){
//        
//        [SVProgressHUD showInfoWithStatus:@"图片名不能包含后缀"];
//    }else{
    
//        NSString * uploadPath = @"diretory/ccww.png";
//        if (self.ftpPath) {
//            uploadPath = [self.ftpPath stringByAppendingString:[NSString stringWithFormat:@"%@/%@.png",_dirArr[indexPath.row],self.picNameTF.text]];
//        }else{
        NSString * uploadPath = [self.ftpPath stringByAppendingString:[NSString stringWithFormat:@"%@.png",[UUIDUtil getUUIDString]]];
        
        
        [self.ftpManager addRequestForUploadFileAtLocalPath:_currentUploadImage toRemotePath:uploadPath];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"WWcreateDirectory"];
        [self.ftpManager startProcessingRequests];
//    }
}

#pragma mark - 删除文件夹/文件
#pragma mark == 左滑点击删除事件
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"删除" message:@"删除确认!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction * sure   = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                /// 移除选择文件夹界面
                //            [self.picTableView removeFromSuperview];
                // 删除
                
                [self removeFileAt:indexPath];
                
            }];
            [alertVC addAction:cancel];
            [alertVC addAction:sure];
            
            [self presentViewController:alertVC animated:YES completion:^{
                //            [SVProgressHUD showInfoWithStatus:@""];
            }];
        }
    
    
}
#pragma mark  调用manager删除文件
- (void) removeFileAt:(NSIndexPath *)indexPath{

//    [_fileDirectoryArr removeObjectAtIndex:indexPath.row];
//    [_fileTypeArr removeObjectAtIndex:indexPath.row];
//    [self.tableView reloadData];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    _deleteIndexPath = indexPath;
    NSString * deletePath;
    if (self.ftpPath) {
        deletePath = [self.ftpPath stringByAppendingString:[NSString stringWithFormat:@"%@",_fileDirectoryArr[indexPath.row]]];
    }else{
        deletePath = [NSString stringWithFormat:@"/%@",_fileDirectoryArr[indexPath.row]];
    }
    
 
    // 判断当前要删除的是文件/文件夹?
    if ([_fileTypeArr[indexPath.row] integerValue] == 8) {// 文件
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"WWcreateDirectory"];
        [self.ftpManager addRequestForDeleteFileAtPath:deletePath];
        [self.ftpManager startProcessingRequests];
        
        [SVProgressHUD showProgress:-1 status:@""];
        
    }else if ([_fileTypeArr[indexPath.row] integerValue] == 4){
        
        deletePath = [deletePath stringByAppendingString:@"/"];
//        deletePath = [deletePath substringFromIndex:1];
        // 文件夹

        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"WWcreateDirectory"];
//        [self.ftpManager addRequestForDeleteFileAtPath:deletePath];
        [self.ftpManager addRequestForDeleteDirectoryAtPath:deletePath];
        [self.ftpManager startProcessingRequests];
        [SVProgressHUD showProgress:-1 status:@""];
    }
    
    
}


#pragma mark  左滑的显示文字
-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}
#pragma mark  侧滑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger fileLayer = [self.navigationController.viewControllers indexOfObject:self];
    if (fileLayer == 4) {
            // 可以移出服务队
            return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

/*
#pragma mark - 上传图片
- (void) uploadPicAction{

//    [self.menuView removeFromSuperview];
    self.menuView.hidden = YES;
    [self pickImage];
    
}
 */
#pragma mark = 选择图片按钮
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

#pragma mark = 打开相机、相册 index 1：相机   2：相册
- (void) openCameraOrAlbum:(NSInteger)index{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; //隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
    NSInteger  sourceType = 0;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (index) {
            case 1:{
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                
//                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//                imagePickerController.delegate = self;
//                imagePickerController.allowsEditing = YES;
//                imagePickerController.sourceType = sourceType;
//                [self presentViewController:imagePickerController animated:YES completion:^{}];
            }
                break;
            case 2:{
                // 相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                NSInteger count = 9;
//                [JFImagePickerController setMaxCount:count];
//                JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:[UIViewController new]];
//                picker.pickerDelegate = self;
//                
//                [self.navigationController presentViewController:picker animated:YES completion:nil];
            }
                break;
        }
    }
    else {
        
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
//        NSInteger count = 9;
//        [JFImagePickerController setMaxCount:count];
//        JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:[UIViewController new]];
//        picker.pickerDelegate = self;
//        
//        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
    
    // 跳转到相机或相册页面
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        }else{
                [JFImagePickerController setMaxCount:9];
                JFImagePickerController * jfVC = [[JFImagePickerController alloc] initWithRootViewController:[UIViewController new]];
                jfVC.pickerDelegate = self;
                [self presentViewController:jfVC animated:YES completion:nil];

    }
    
    
    
    /*
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
     */
    
}
#pragma mark - JFImagePicker Delegate -

- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    __weak typeof(self) weakself = self;
    for (ALAsset *asset in picker.assets) {
        [[JFImageManager sharedManager] imageWithAsset:asset resultHandler:^(CGImageRef imageRef, BOOL longImage) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_photosArray.count == 0) {
                    [_photosArray addObject:image];
                    [self uploadPicOneTime:image];
                }else{
                    [_photosArray addObject:image];
                }
//                [_photosArray addObject:image];
//                [weakself refreshCollectionView];
                
                
            });
        }];
    }
    [self imagePickerDidCancel:picker];
}

- (void) uploadPicOneTime:(UIImage *)image{

    NSData *imageData = UIImageJPEGRepresentation(image,0.1);
    NSString *strname = @"Documents/currentUpload.png";
    
    
    NSString *filePath1=[NSHomeDirectory() stringByAppendingPathComponent:strname];
    [imageData writeToFile:filePath1 atomically:YES];
    NSLog(@"%@",filePath1);
    _currentUploadImage = filePath1;
    [self sureUploadAcion];
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [JFImagePickerController clear];
}

#pragma  mark - imagePickerController Delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self imageHandleWithpickerController:picker MdediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imageHandleWithpickerController:(UIImagePickerController *)picker MdediaInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_photosArray addObject:image];
    [self uploadPicOneTime:image];
//    [self refreshCollectionView];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}
/*
#pragma mark = 选完图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; //隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    //      UIImagePickerControllerEditedImage
    UIImage *image1 = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSDictionary * dic = [info objectForKey:UIImagePickerControllerMediaMetadata];
    NSLog(@"**********************%@",dic);
    
    NSData *imageData = UIImageJPEGRepresentation(image1,0.1);
    NSString *strname = @"Documents/currentUpload.png";
    
    
    NSString *filePath1=[NSHomeDirectory() stringByAppendingPathComponent:strname];
    [imageData writeToFile:filePath1 atomically:YES];
    NSLog(@"%@",filePath1);
    _currentUploadImage = filePath1;
    
    // 蒙版
    _dirArr = [[NSMutableArray alloc] initWithArray:_fileDirectoryArr];
    NSInteger count = 0;
    for (int i = 0; i<_fileTypeArr.count; i++) {
        if ([_fileTypeArr[i] integerValue] == 8) {
            [_dirArr removeObjectAtIndex:i-count];
            count++;
        }
    }
    [_dirArr insertObject:@"/" atIndex:0];
    self.coverBtn.hidden = NO;
    self.uploadImage.image = [UIImage   imageWithContentsOfFile:_currentUploadImage];
    self.uploadImage.hidden = NO;
//    self.picNameTF.hidden = NO;
    self.uploadBtn.hidden = NO;
//    [self.view addSubview:self.picTableView];
    
    //////
//    [self.ftpManager addRequestForUploadFileAtLocalPath:filePath1 toRemotePath:@"dir/cc.png"];
//    [self.ftpManager startProcessingRequests];
}
*/
#pragma mark - upload回调
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request{
    
    [SVProgressHUD showInfoWithStatus:@"上传成功!"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_currentUploadImage error:nil];
    
    self.picNameTF.text = @"";
    
    if (_photosArray.count-1>=_uploadIndex) {
        
        [self uploadPicOneTime:_photosArray[_uploadIndex]];
        _uploadIndex++;
//        NSLog(@"0000000000000%ld",_uploadIndex);
    }else{
        _uploadIndex = 1;
        [_photosArray removeAllObjects];
    }
    
    
    
    _dirArr = nil;
    self.uploadImage.hidden = YES;
//    self.picNameTF.hidden   = YES;
    self.coverBtn.hidden    = YES;
    
//    self.picTableView.hidden = YES;
//    [self.picTableView removeFromSuperview];
    self.uploadBtn.hidden = YES;
//    self.picTableView = nil;
    // 刷新目录
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"WWcreateDirectory"];
    [self.ftpManager addRequestForListDirectoryAtPath:_refreshPah];
    [self.ftpManager startProcessingRequests];
    [SVProgressHUD showProgress:-1 status:@""];
    
}

#pragma mark - 蒙版点击事件
- (void) coverAction:(UIButton *) cover{

//    [self.picTableView removeFromSuperview];
//    self.picTableView = nil;
    self.uploadBtn.hidden = YES;
    
    cover.hidden = YES;
    
    self.menuView.hidden = YES;
    
    _dirArr = nil;
    
    self.uploadImage.hidden = YES;
//    self.picNameTF.hidden   = YES;
    // > 从本地删除选中的图片
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_currentUploadImage error:nil];
}

#pragma mark - pop控制器
- (void) popAction:(UIButton *)btn{
    
    PopSelectViewController * tipVC  = [[PopSelectViewController alloc] initWithNibName:@"PopSelectViewController" bundle:[NSBundle mainBundle]];
    self.popVC = tipVC;
    tipVC.itemArr = @[@"上传图片",@"新建文件夹"];
    tipVC.popDelegate = self;
    tipVC.preferredContentSize = CGSizeMake(110, 80);
    tipVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController * popVC = tipVC.popoverPresentationController;
    popVC.delegate = self;
    popVC.sourceView = btn;
    popVC.sourceRect = CGRectMake(10, btn.frame.size.height, 0, 0);
    tipVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:tipVC animated:YES completion:nil];
}

#pragma mark = popViewController 的代理方法，实现该方法才能够局部弹出控制器
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
}
#pragma mark = pop代理回调
- (void) changeTextFiledContentWith:(NSString *)newContent{
    
    [self.popVC dismissViewControllerAnimated:YES completion:nil];
    if ([newContent isEqualToString:@"上传图片"]) {
//        [self pickImage];
    }else if([newContent isEqualToString:@"新建文件夹"]){
        [self createDirectory];
    }
    
}

#pragma mark - 新建文件夹
- (void) createDirectory{
    
    UIAlertController * directoryVC = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [directoryVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.placeholder = @"请填写姓名";
    }];
    [directoryVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请填写身份证号码";
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    
        //> 获取文件名
        UITextField * name = [directoryVC.textFields firstObject];
        UITextField * idNumber = [directoryVC.textFields objectAtIndex:1];
        
        
        if (name.text.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"请填写姓名"];
        }else if (![checkString  validateCertNo:idNumber.text]){
//
            [SVProgressHUD showInfoWithStatus:@"请填写正确的身份证号码"];
        }else{
            
            NSString * newDirectoryName = [NSString stringWithFormat:@"%@-%@",name.text,idNumber.text];;
//
            
            NSString * createPath;
            if (self.ftpPath) {
                createPath = self.ftpPath;
            }else{
                createPath = @"/";
            }
            
            _personPath = [createPath stringByAppendingString:[NSString stringWithFormat:@"%@/",newDirectoryName]];
            /**
             * 新建文件夹的处理
             */
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"createDirectory" forKey:@"WWcreateDirectory"];
            
            NSString * encodeCreatePath = [self createEncodeString:createPath];
            
            [defaults setObject:encodeCreatePath forKey:@"WWencodeCreatePath"];
            
            [self.ftpManager addRequestForCreateDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",createPath,newDirectoryName]];
            [self.ftpManager startProcessingRequests];
            [SVProgressHUD showProgress:-1 status:@"正在创建..."];
        }
        
    }];
    
    [directoryVC addAction:cancelAction];
    [directoryVC addAction:sureAction];
    
    [self presentViewController:directoryVC animated:YES completion:nil];
    
    
    
}

#pragma mark 针对新建文件夹的编码
- (NSString *)createEncodeString:(NSString *)string;
{
    NSString *urlEncoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                 NULL,
                                                                                                 (__bridge CFStringRef) string,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'\"();:@&=+$,?%#[]% ",
                                                                                                 kCFStringEncodingUTF8);
    return urlEncoded;
}


@end
