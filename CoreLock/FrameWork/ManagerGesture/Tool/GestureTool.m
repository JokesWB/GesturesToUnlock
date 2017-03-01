//
//  GestureTool.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "GestureTool.h"

NSString *const switchKeyString = @"changeSwitchStatus";   //开关key
NSString *const switchStatus = @"switchStatus";    //保存开关状态

@implementation GestureTool

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)boolForKey:(NSString *)defaultName
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}

@end
