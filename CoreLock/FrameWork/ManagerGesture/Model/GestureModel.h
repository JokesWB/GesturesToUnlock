//
//  GestureModel.h
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GestureModel : NSObject

@property (nonatomic , copy) NSString *imageName;
@property (nonatomic , copy) NSString *title;
@property (nonatomic , copy) dispatch_block_t clickItem;  //点击某个item

+ (id)setImageName:(NSString *)imageName Title:(NSString *)title;

+ (id)setTitle:(NSString *)title;

@end
