//
//  GestureTool.h
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const switchKeyString;
extern NSString *const switchStatus;

@interface GestureTool : NSObject

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

+ (BOOL)boolForKey:(NSString *)defaultName;



@end
