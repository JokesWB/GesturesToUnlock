//
//  GestureSwitchModel.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "GestureSwitchModel.h"
#import "GestureTool.h"

@implementation GestureSwitchModel

- (void)setKeyStr:(NSString *)keyStr
{
    _keyStr = keyStr;
    //读取
    _on = [GestureTool boolForKey:_keyStr];
}

- (void)setOn:(BOOL)on
{
    _on = on;
    //保存
    [GestureTool setBool:_on forKey:self.keyStr];
}

@end
