////
////  SweepVC.m
////  MyTabBarCenter
////
////  Created by AcHu on 15/9/30.
////  Copyright © 2015年 oc. All rights reserved.
////
//
//#import "SweepVC.h"
//#import <AVFoundation/AVFoundation.h>
//
//@interface SweepVC ()<AVCaptureMetadataOutputObjectsDelegate>
//@property (nonatomic,assign)NSInteger num;//扫描线移动位移量
//@property (nonatomic,assign)BOOL      upOrdown;//判断扫描线的上下移动
//@property (nonatomic,strong)UIImageView *imageView;//扫描框
//@property (strong, nonatomic) UIView *pikebgView;//相机视图所站区域
//@property (nonatomic, retain) UIImageView * line;//扫描线
//@property (strong,nonatomic)AVCaptureSession *session;
//@property(strong,nonatomic)NSTimer * timer;//控制扫描线的移动时间
//
//@property(strong,nonatomic)UIButton *lightBtn;
//@end
//
//@implementation SweepVC
//
//-(void)dealloc{
//    if (_session) {
//        [_session stopRunning];
//    }
//}
//
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//    if (captureDeviceClass != nil) {
//        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        if ([device hasTorch]) { // 判断是否有闪光灯
//            // 请求独占访问硬件设备
//            [device lockForConfiguration:nil];
//            [device setTorchMode:AVCaptureTorchModeOff]; // 手电筒关
//            // 请求解除独占访问硬件设备
//            [device unlockForConfiguration];}
//    }
//    _lightBtn.selected = NO;
//    [self removeTimer];
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self startTimer];
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.title = @"码上扫";
//    _pikebgView = [[UIView alloc]init];
//    _pikebgView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    _pikebgView.bounds = CGRectMake(0, 0, self.view.frame.size.width-80, self.view.frame.size.width-50);
//    [self.view addSubview:_pikebgView];
//    _upOrdown = NO;
//    _num = 0;
//    //    self.title = @"扫一扫";
//    
//    _imageView=[[UIImageView alloc]init];
//    _imageView.center=CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - 64)/2);
//    _imageView.bounds=CGRectMake(0, 0, ScreenWide - 2 * 60, ScreenWide - 2 * 60);
//    _imageView.image=[UIImage imageNamed:@"sweepFrame"];
//    [self.view addSubview:_imageView];
//    _line = [[UIImageView alloc] initWithFrame:CGRectMake(3, 10, _imageView.frame.size.width - 6, 2)];
//    _line.image = [UIImage imageNamed:@"sweepLine"];
//    _line.contentMode = UIViewContentModeScaleToFill;
//    [_imageView addSubview:_line];
//    
//    int systemVersion = [[[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] componentsSeparatedByString:@"."].firstObject intValue];
//    if (systemVersion >= 8) {
//        UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWide, ScreenHeight)];
//        oneView.backgroundColor = [UIColor blackColor];
//        oneView.alpha = 0.3;
//        [self.view addSubview:oneView];
//        
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, ScreenWide, ScreenHeight)];
//        [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(_imageView.frame),CGRectGetMinY(_imageView.frame), VIEW_W(_imageView), VIEW_H(_imageView))].bezierPathByReversingPath];
//        CAShapeLayer *shape = [CAShapeLayer new];
//        shape.backgroundColor = [UIColor clearColor].CGColor;
//        shape.path = path.CGPath;
//        oneView.layer.mask = shape;
//    }
//    
//    UIImageView *topImageView = [[UIImageView alloc]initWithFrame:CGRectMake((VIEW_W(self.view) - 220) / 2., VIEW_YMIN(_imageView) - 32 - 20, 220, 32)];
//    topImageView.image = ImageName(@"sweepTopLabl");
//    [self.view addSubview:topImageView];
//    
//    UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    lightBtn.image = ImageName(@"sweepFlashlight");
//    lightBtn.selectImage = ImageName(@"sweepFlashlightS");
//    lightBtn.frame = CGRectMake((VIEW_W(self.view) - 64) / 2., VIEW_YMAX(_imageView) + 15, 64, 64);
//    [lightBtn addTarget:self action:@selector(lightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:lightBtn];
//    
//    
//}
//
//-(void)startTimer{
//    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
//        [self start];
//    }
//}
//
//-(void)removeTimer{
//    if (!_timer) {
//        [_timer invalidate];
//        _timer = nil;
//    }
//}
//
//- (void)lightBtnClick:(UIButton *)btn{
//    btn.selected = !btn.selected;
//    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//    if (captureDeviceClass != nil) {
//        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        if ([device hasTorch]) { // 判断是否有闪光灯
//            // 请求独占访问硬件设备
//            [device lockForConfiguration:nil];
//            if (btn.selected == YES) {
//                [device setTorchMode:AVCaptureTorchModeOn]; // 手电筒开
//            }else{
//                [device setTorchMode:AVCaptureTorchModeOff]; // 手电筒关
//            }
//            // 请求解除独占访问硬件设备
//            [device unlockForConfiguration];}
//    }
//}
//
//#pragma mark 相机扫描线的移动动画
//-(void)animation1
//{
//    if (_upOrdown == NO) {
//        _num ++;
//        _line.frame = CGRectMake(CGRectGetMinX(_line.frame), 20+2*_num, _line.frame.size.width, CGRectGetHeight(_line.frame));
//        if (2*_num >= CGRectGetHeight(_imageView.frame)-35) {
//            _upOrdown = YES;
//        }
//    }
//    else {
//        _num --;
//        _line.frame = CGRectMake(CGRectGetMinX(_line.frame), 20+2*_num, _line.frame.size.width, CGRectGetHeight(_line.frame));
//        if (_num == 0) {
//            _upOrdown = NO;
//        }
//    }
//}
//
//#pragma mark 判断是否打开相机-并初始化相机相关设置
//- (void)start {
//    void (^checkCamera)(void) = ^(){
//        self.view.backgroundColor = [UIColor whiteColor];
//        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        if ([[UIApplication sharedApplication] canOpenURL:url]) {
//            //打开相机提示框
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:@"你没有摄像头\n请在设备的\"设置-隐私-相机\"中允许访问相机。"
//                                                           delegate:self cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"设置",nil];
//            [alert show];
//        }
//    };
//    NSString *mediaType = AVMediaTypeVideo;
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
//    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
//        checkCamera();
//        return;
//    }
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
////        AVF_EXPORT AVMediaType const AVMediaTypeVideo                 NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeAudio                 NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeText                  NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeClosedCaption         NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeSubtitle              NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeTimecode              NS_AVAILABLE(10_7, 4_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeMetadata              NS_AVAILABLE(10_8, 6_0);
////        AVF_EXPORT AVMediaType const AVMediaTypeMuxed                 NS_AVAILABLE(10_7, 4_0);
//        //获取摄像设备
//        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        //创建输入流
//        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
//        //创建输出流
//        AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
//        //设置代理 在主线程里刷新
//        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//        //设置扫描区域，中心点反转，屏幕百分比
//        [output setRectOfInterest : CGRectMake(CGRectGetMinY(_imageView.frame)/self.view.frame.size.height, CGRectGetMinX(_imageView.frame)/self.view.frame.size.width, _imageView.frame.size.height/self.view.frame.size.height, _imageView.frame.size.width/self.view.frame.size.width)];
////        [output setRectOfInterest : CGRectMake(CGRectGetMinY(self.view.frame)/self.view.frame.size.height, CGRectGetMinX(self.view.frame)/self.view.frame.size.width, self.view.frame.size.height/self.view.frame.size.height, self.view.frame.size.width/self.view.frame.size.width)];
////         [output setRectOfInterest : self.view.bounds];
//        
//        
//        //初始化链接对象
//        _session = [[AVCaptureSession alloc] init];
//        //高质量采集率
//        [_session setSessionPreset:AVCaptureSessionPresetHigh];
//        
//        [_session addInput:input];
//        [_session addOutput:output];
//        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
//        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,
//                                     AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
//        
//        AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
//        layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
//        layer.frame=self.view.layer.bounds;
//        
//        [self.view.layer insertSublayer:layer atIndex:0];
//        
//        //开始捕获
//        [_session startRunning];
//    }else{
//        //如果没有提示用户
//        checkCamera();
//    }
//}
//
//#pragma mark ---扫描结果后执行的操作-打开网页AVCaptureMetadataOutputObjectsDelegate ---
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
//{
//    NSString *stringValue;
//    if ([metadataObjects count] >0)
//    {
//        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
//        //扫描字符串
//        stringValue = metadataObject.stringValue;
//    }
//    
//    [_session stopRunning];
//    [_timer invalidate];
//    
//    HuLog(@"%@",stringValue);
//    
//    if ([NSString isEmptyStr:stringValue]) {
//        [SVProgressHUD showStr:stringValue];
//        return;
//    }
//    if (self.scanResult) {
//        self.scanResult(stringValue);
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}
//
//#pragma mark 提示框点击设置后去执行设置相机
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex==1) {
//        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        [[UIApplication sharedApplication] openURL:url];
//    }
//}
//
//@end
//
//
//
//
//
//
