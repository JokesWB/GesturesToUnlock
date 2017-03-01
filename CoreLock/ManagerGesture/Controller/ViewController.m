//
//  ViewController.m
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "ViewController.h"
#import "CLLockVC.h"
#import "ManagerGestureTableViewController.h"
#import "GestureTool.h"
#import "LoginViewController.h"
#import "CoreArchive.h"
#import "CoreLockConst.h"





@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //读取开关状态
    BOOL result = [GestureTool boolForKey:switchStatus];
    
    NSLog(@"%d", result);
    if (result) {
        [CLLockVC showVerifyLockVCInVC:self forgetPwdBlock:^(CLLockVC *lockVC){
            
            //忘记密码
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            //登录成功
            __weak typeof(loginVC) weakLoginVC = loginVC;
            loginVC.loginSuccess = ^(){
                
                [CoreArchive removeStrForKey:CoreLockPWDKey];  //删除密码
                [GestureTool setBool:NO forKey:switchStatus];  //保存开关状态
                [weakLoginVC dismissViewControllerAnimated:YES completion:nil];
            };
            
            [lockVC.navigationController pushViewController:loginVC animated:YES];
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:0.5];
        }];
    }

}

- (IBAction)nextPage:(UIButton *)sender {
    
    ManagerGestureTableViewController *vc = [[ManagerGestureTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com