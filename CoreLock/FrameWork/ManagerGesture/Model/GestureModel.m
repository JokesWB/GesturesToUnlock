//
//  GestureModel.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "GestureModel.h"

@implementation GestureModel

+ (id)setImageName:(NSString *)imageName Title:(NSString *)title
{
    GestureModel *model = [[self alloc] init];
    model.imageName = imageName;
    model.title = title;
    return model;
}

+ (id)setTitle:(NSString *)title
{
    return [self setImageName:nil Title:title];
}

@end
