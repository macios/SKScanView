//
//  ViewController.m
//  SKScanView
//
//  Created by ac-hu on 2018/11/7.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

#import "ViewController.h"
#import "SKScanView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SKScanView *view = [[SKScanView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    view.wireframeBounds = CGRectMake(0, 0, 100, 100);
    view.scanResult = ^(NSString *qrCode) {
        NSLog(@"%@",qrCode);
    };
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
