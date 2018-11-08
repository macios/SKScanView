//
//  SKScanView.h
//  SKScanView
//
//  Created by ac-hu on 2018/11/8.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKScanView : UIView
@property (nonatomic,copy)void(^scanResult)(NSString *qrCode);  // 返回扫描结果
@property(nonatomic,assign)CGRect wireframeBounds;
@end
