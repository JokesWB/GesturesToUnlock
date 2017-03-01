//
//  GestureSwitchModel.h
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "GestureModel.h"
#import <UIKit/UIKit.h>

@interface GestureSwitchModel : GestureModel

@property (nonatomic , copy) NSString *keyStr;
@property (nonatomic , assign) BOOL on;
@property (nonatomic , copy) void (^clickSwitchBtn) (UISwitch *);    //点击了开关按钮

@end
