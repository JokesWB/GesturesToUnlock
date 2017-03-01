//
//  GestureCell.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "GestureCell.h"
#import "GestureModel.h"
#import "GestureArrowModel.h"
#import "GestureSwitchModel.h"

@interface GestureCell ()

@property (nonatomic , strong) UIImageView *arrowImageView;
@property (nonatomic , strong) UISwitch *gestureSwitch;

@end

@implementation GestureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setGestureModel:(GestureModel *)gestureModel
{
    _gestureModel = gestureModel;
    self.textLabel.text = _gestureModel.title;
    
    if ([_gestureModel isKindOfClass:[GestureArrowModel class]]) {
        self.accessoryView = self.arrowImageView;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([_gestureModel isKindOfClass:[GestureSwitchModel class]]) {
        GestureSwitchModel *switchModel = (GestureSwitchModel *)_gestureModel;
        self.gestureSwitch.on = switchModel.on;
        self.accessoryView = self.gestureSwitch;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}


//点击了开关按钮
- (void)clickSwitchAction:(UISwitch *)sender
{
    GestureSwitchModel *switchModel = (GestureSwitchModel *)self.gestureModel;
    if (switchModel.clickSwitchBtn) {
        switchModel.clickSwitchBtn(sender);
    }
}


- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_zhankai"]];
    }
    return _arrowImageView;
}

- (UISwitch *)gestureSwitch
{
    if (!_gestureSwitch) {
        _gestureSwitch = [[UISwitch alloc] init];
        [_gestureSwitch addTarget:self action:@selector(clickSwitchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _gestureSwitch;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
