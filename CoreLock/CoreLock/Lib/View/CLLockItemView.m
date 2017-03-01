//
//  CLLockItemView.m
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "CLLockItemView.h"
#import "CoreLockConst.h"

@interface CLLockItemView ()

/** 圆环rect */
@property (nonatomic,assign) CGRect calRect;

/** 选中的rect */
@property (nonatomic,assign) CGRect selectedRect;

/** 角度 */
@property (nonatomic,assign) CGFloat angle;

@property (nonatomic , strong) UIImageView *imageView;

@end


@implementation CLLockItemView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
         self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}



-(void)drawRect:(CGRect)rect
{
    //设置未选中的图片 和 选中的图片
    UIImage *image = _selected ? [UIImage imageNamed:@"bn_jiesuo_anxia"] : [UIImage imageNamed:@"bn_jiesuo1"];
    self.imageView.image = image;

}


-(void)setSelected:(BOOL)selected{
    
    _selected = selected;
    
    [self setNeedsDisplay];
}


//方向
-(void)setDirect:(LockItemViewDirect)direct{
    
    _direct = direct;
    
    self.angle = M_PI_4 * (direct -1);
    
    [self setNeedsDisplay];
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return _imageView;
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com