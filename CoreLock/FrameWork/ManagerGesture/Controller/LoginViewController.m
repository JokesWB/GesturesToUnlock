//
//  LoginViewController.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *TF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
}

- (IBAction)loginBtnAction:(UIButton *)sender {
    
    if (self.TF.text.length >= 3) {
        NSLog(@"登录成功");
        
        if (self.loginSuccess) {
            self.loginSuccess();
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


@end
