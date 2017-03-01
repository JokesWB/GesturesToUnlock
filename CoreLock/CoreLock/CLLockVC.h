//
//  CLLockVC.h
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    
    //设置密码
    CoreLockTypeSetPwd=0,
    
    //输入并验证密码
    CoreLockTypeVeryfiPwd,
    
    //修改密码
    CoreLockTypeModifyPwd,
    
}CoreLockType;



@interface CLLockVC : UIViewController

@property (nonatomic,assign) CoreLockType type;

@property (nonatomic , assign) BOOL showVerifyCancelBtn;  //是否显示取消验证按钮

/*
 *  是否有本地密码缓存？即用户是否设置过初始密码？
 */
+(BOOL)hasPwd;





/*
 *  展示设置密码控制器
 */
+(instancetype)showSettingLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock CancelSetPwdBlock:(void(^)(CLLockVC *lockVC))cancelSetPwdBlock;



/*
 *  展示验证密码输入框
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc forgetPwdBlock:(void(^)(CLLockVC *lockVC))forgetPwdBlock successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock;

/*
 *  展示验证密码输入框, 带有取消验证按钮的
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc forgetPwdBlock:(void(^)(CLLockVC *lockVC))forgetPwdBlock successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock cancelVerifyPwdBlock:(void(^)(CLLockVC *lockVC))cancelVerifyPwdBlock;


/*
 *  展示修改密码输入框
 */
+(instancetype)showModifyLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock;


/*
 *  消失
 */
-(void)dismiss:(NSTimeInterval)interval;





















@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com