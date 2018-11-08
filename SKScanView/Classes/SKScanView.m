//
//  SKScanView.m
//  SKScanView
//
//  Created by ac-hu on 2018/11/8.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

//
//  SweepVC3.m
//  MyTabBarCenter
//
//  Created by AcHu on 15/9/30.
//  Copyright © 2015年 oc. All rights reserved.
//

#import "SKScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface SKScanView ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong)UIImageView *imageView;//扫描框
@property (nonatomic, retain) UIImageView * line;//扫描线
@property(strong,nonatomic)UIView *shadeView;
@property (strong,nonatomic)AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (nonatomic,strong)UIView  *focusView;//聚焦视图
@property(nonatomic,assign)CGFloat beginGestureScale;//记录开始的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;//最后的缩放比例
@end

@implementation SKScanView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatView];
    }
    return self;
}

-(void)dealloc{
    if (_session) {
        [_session stopRunning];
    }
}

- (void)creatView {
    self.effectiveScale = self.beginGestureScale = 1.0f;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    _imageView=[[UIImageView alloc]init];
    _imageView.center = CGPointMake(self.frame.size.width * .5, self.frame.size.height * .5);
    CGFloat wireframeWidth = (screenWidth - 2 * 78) / screenWidth * self.frame.size.width;
    _wireframeBounds = CGRectMake(0, 0, wireframeWidth, wireframeWidth);
    _imageView.image = [UIImage imageNamed:@"SKScanWireframe.png"];
    [self addSubview:_imageView];
    
    _line = [[UIImageView alloc] init];
    _line.image = [UIImage imageNamed:@"SKScanLine.png"];
    _line.contentMode = UIViewContentModeScaleToFill;
    [_imageView addSubview:_line];
    
    _shadeView = [[UIView alloc]init];
    _shadeView.backgroundColor = [UIColor blackColor];
    _shadeView.alpha = 0.3;
    [self addSubview:_shadeView];
    
    //聚焦视图
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self addSubview:_focusView];
    _focusView.hidden = YES;
    
    //点击对焦手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    [self realodFrame];
    [self start];
}



-(void)realodFrame{
    _imageView.bounds = _wireframeBounds;
    _line.frame = CGRectMake(3, 10, _imageView.frame.size.width - 6, 2);
    _shadeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_shadeView.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(_imageView.frame),CGRectGetMinY(_imageView.frame), CGRectGetWidth(_imageView.frame), CGRectGetHeight(_imageView.frame))].bezierPathByReversingPath];
    CAShapeLayer *shape = [CAShapeLayer new];
    shape.backgroundColor = [UIColor clearColor].CGColor;
    shape.path = path.CGPath;
    _shadeView.layer.mask = shape;
    
    CABasicAnimation * animaiton = [CABasicAnimation animationWithKeyPath:@"position.y"];
    //    position center
    animaiton.removedOnCompletion = NO;
    animaiton.repeatCount = MAXFLOAT;//重复次数
    animaiton.autoreverses = YES;//是否执行反向动画
    animaiton.duration = 1.5;
    animaiton.toValue = @(_imageView.bounds.size.height - CGRectGetMinY(_line.frame));
    [_line.layer addAnimation:animaiton forKey:nil];
}

-(void)setWireframeBounds:(CGRect)wireframeBounds{
    _wireframeBounds = wireframeBounds;
    [self realodFrame];
}

#pragma mark 判断是否打开相机-并初始化相机相关设置
- (void)start {
    void (^checkCamera)(void) = ^(){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            //打开相机提示框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头\n请在设备的\"设置-隐私-相机\"中允许访问相机。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置",nil];
            [alert show];
        }
    };
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        checkCamera();
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //获取摄像设备
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        //创建输出流
        self.output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置扫描区域，中心点反转，屏幕百分比
        [self.output setRectOfInterest : CGRectMake(CGRectGetMinY(_imageView.frame)/self.frame.size.height, CGRectGetMinX(_imageView.frame)/self.frame.size.width, _imageView.frame.size.height/self.frame.size.height, _imageView.frame.size.width/self.frame.size.width)];
        
        //初始化链接对象
        _session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [_session addInput:input];
        [_session addOutput:self.output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,
                                     AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.layer.bounds;
//        [self.layer insertSublayer:[[self.layer sublayers] atIndex:0];
        [self.layer insertSublayer:self.previewLayer below:[[self.layer sublayers] objectAtIndex:0]];
        //开始捕获
        [_session startRunning];
    }else{
        //如果没有提示用户
        checkCamera();
    }
}

#pragma mark - 相机操作相关
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        typeof(self) __weak weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                weakSelf.focusView.hidden = YES;
            }];
        }];
    }
}


#pragma mark ---扫描结果后执行的操作-打开网页AVCaptureMetadataOutputObjectsDelegate ---
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        //扫描字符串
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    [_line.layer removeAllAnimations];
    
    if (stringValue == nil) {
        NSLog(@"未扫描出结果");
        [self start];
        return;
    }
    if (self.scanResult) {
        self.scanResult(stringValue);
    }
}

#pragma mark 提示框点击设置后去执行设置相机
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end


