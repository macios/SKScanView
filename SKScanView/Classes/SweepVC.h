//
//  SweepVC3.h
//  SweepVC3
//
//  Created by AcHu on 15/9/30.
//  Copyright © 2015年 oc. All rights reserved.
//  普通的扫描界面

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "BaseController.h"

@interface SweepVC : UIViewController
@property (nonatomic,copy)void(^scanResult)(NSString *qrCode);  // 返回扫描结果
@property (nonatomic,assign)BOOL           modelView;// 模态View
@end
