//
//  ManagerGestureTableViewController.m
//  CoreLock
//
//  Created by admin on 16/8/22.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "ManagerGestureTableViewController.h"
#import "GestureCell.h"
#import "GestureModel.h"
#import "GestureSwitchModel.h"
#import "GestureArrowModel.h"
#import "GestureTool.h"
#import "CLLockVC.h"
#import "LoginViewController.h"
#import "CoreArchive.h"
#import "CoreLockConst.h"

#define WeakObj(type) autoreleasepool{} __weak typeof(type) type##Weak = type;
#define StrongObj(type) autoreleasepool{} __strong typeof(type) type = type##Weak;

@interface ManagerGestureTableViewController ()

@property (nonatomic , strong) NSMutableArray *listArray;

@property (nonatomic , assign) BOOL switchStatus;  //开关状态

@end

@implementation ManagerGestureTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    [self setUpModel];
    
}

- (void)setUpModel
{
    [self.listArray removeAllObjects];
    
    GestureArrowModel *arrowModel = [GestureArrowModel setTitle:@"修改密码"];
    arrowModel.clickItem = ^(){
        NSLog(@"修改密码");
        self.switchStatus = YES;
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:0.5];
        }];
        //保存开关状态
        [GestureTool setBool:self.switchStatus forKey:switchStatus];
    };
    
    GestureSwitchModel *switchModel = [GestureSwitchModel setTitle:@"手势密码"];
    [self.listArray addObject:switchModel];
    
    @WeakObj(switchModel)
    switchModel.keyStr = switchKeyString;
    
    if (switchModel.on) {
        [self.listArray addObject:arrowModel];
    }
    
    //如果是因为忘记密码用账号登录成功之后，设置开关状态
    if (![CLLockVC hasPwd]) {
        [self.listArray removeObject:arrowModel];
        switchModel.on = NO;
    }
    
    switchModel.clickSwitchBtn = ^(UISwitch *mySwitch){
        @StrongObj(switchModel)
        switchModel.on = mySwitch.on;
        if (mySwitch.on) {
            //打开开关，判断有没有设置过密码
            BOOL hasPwd = [CLLockVC hasPwd];
            if(hasPwd){
                NSLog(@"已经设置过密码了，你可以验证或者修改密码");
                self.switchStatus = YES;
                //保存开关状态
                [GestureTool setBool:self.switchStatus forKey:switchStatus];
                
                [self.listArray addObject:arrowModel];
                [self.tableView reloadData];
                return;
            }else{
                [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                    NSLog(@"密码设置成功");
                    self.switchStatus = YES;
                    //保存开关状态
                    [GestureTool setBool:self.switchStatus forKey:switchStatus];
                    
                    [lockVC dismiss:0.5f];
                    [self.listArray addObject:arrowModel];
                    [self.tableView reloadData];
                } CancelSetPwdBlock:^(CLLockVC *lockVC) {
                    [lockVC dismiss:0];
                    self.switchStatus = NO;
                    //保存开关状态
                    [GestureTool setBool:self.switchStatus forKey:switchStatus];
                    
                    //关闭开关
                    switchModel.on = !mySwitch.on;
                    [self.tableView reloadData];
                }];
            }
            
            
        } else {   //关闭开关，先验证密码
            
            [CLLockVC showVerifyLockVCInVC:self forgetPwdBlock:^(CLLockVC *lockVC){
                self.switchStatus = YES;
                //保存开关状态
                [GestureTool setBool:self.switchStatus forKey:switchStatus];
                //忘记密码
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                //登录成功
                loginVC.loginSuccess = ^(){
                    self.switchStatus = NO;
                    //保存开关状态
                    [GestureTool setBool:self.switchStatus forKey:switchStatus];
                    [CoreArchive removeStrForKey:CoreLockPWDKey];  //删除密码
                    switchModel.on = mySwitch.on;
                    [self.listArray removeObject:arrowModel];
                    [self.tableView reloadData];
                };
                
                [lockVC.navigationController pushViewController:loginVC animated:YES];
                
            } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                self.switchStatus = NO;
                //保存开关状态
                [GestureTool setBool:self.switchStatus forKey:switchStatus];
                [self.listArray removeObject:arrowModel];
                [lockVC dismiss:0.5];  //验证成功，关闭开关
                [self.tableView reloadData];
            } cancelVerifyPwdBlock:^(CLLockVC *lockVC) {
                self.switchStatus = YES;
                //保存开关状态
                [GestureTool setBool:self.switchStatus forKey:switchStatus];
                //取消验证
                [lockVC dismiss:0];
                switchModel.on = !mySwitch.on;
                [self.tableView reloadData];
            }];
            
        }
    };
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    GestureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GestureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.gestureModel = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GestureModel *gesture = self.listArray[indexPath.row];
    if (gesture.clickItem) {
        gesture.clickItem();
    }
}


- (NSMutableArray *)listArray
{
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}


@end
