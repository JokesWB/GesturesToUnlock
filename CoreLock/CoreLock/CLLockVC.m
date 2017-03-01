//
//  CLLockVC.m
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "CLLockVC.h"
#import "CoreLockConst.h"
#import "CoreArchive.h"
#import "CLLockLabel.h"
#import "CLLockNavVC.h"
#import "CLLockView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define WeakObj(type) autoreleasepool{} __weak typeof(type) type##Weak = type;
#define StrongObj(type) autoreleasepool{} __strong typeof(type) type = type##Weak;

@interface CLLockVC ()

/** 操作成功：密码设置成功、密码验证成功 */
@property (nonatomic,copy) void (^successBlock)(CLLockVC *lockVC,NSString *pwd);

@property (nonatomic,copy) void (^forgetPwdBlock)(CLLockVC *lockVC);

@property (nonatomic , strong) CLLockLabel *label;

@property (nonatomic,copy) NSString *msg;

@property (nonatomic , strong) CLLockView *lockView;

@property (nonatomic,weak) UIViewController *vc;

@property (nonatomic,strong) UIBarButtonItem *resetItem;


@property (nonatomic,copy) NSString *modifyCurrentTitle;


@property (nonatomic , strong) UIView *actionView;

@property (nonatomic , strong) UIButton *modifyBtn;  //修改密码
@property (nonatomic , strong) UIButton *forgetBtn;   //忘记密码

/** 直接进入修改页面的 */
@property (nonatomic,assign) BOOL isDirectModify;

@property (nonatomic , copy) void (^cancelSetPwdBlock) (CLLockVC *lockVC);   //取消设置密码

@property (nonatomic , copy) void (^cancelVerifyPwdBlock) (CLLockVC *lockVC);   //取消验证密码

@end

@implementation CLLockVC

- (CLLockLabel *)label
{
    if (!_label) {
        _label = [[CLLockLabel alloc] initWithFrame:CGRectMake(0, 100, SCREENWIDTH, 30)];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_label];
    }
    return _label;
}

- (CLLockView *)lockView
{
    if (!_lockView) {
        _lockView = [[CLLockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.label.frame) + 50, SCREENWIDTH, SCREENWIDTH)];
        _lockView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_lockView];
    }
    return _lockView;
}

- (UIView *)actionView
{
    if (!_actionView) {
        _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 50, SCREENWIDTH, 30)];
        [self.view addSubview:_actionView];
    }
    return _actionView;
}

- (void)addforgetBtnAndModifyBtn
{
    self.modifyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.modifyBtn.frame = CGRectMake(10, 0, 100, 30);
    [self.modifyBtn setTitle:@"修改密码" forState:UIControlStateNormal];
    [self.modifyBtn addTarget:self action:@selector(modityBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.actionView addSubview:self.modifyBtn];
    
    self.forgetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.forgetBtn.frame = CGRectMake(SCREENWIDTH - 110, 0, 100, 30);
    [self.forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [self.forgetBtn addTarget:self action:@selector(forgetBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.actionView addSubview:self.forgetBtn];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    

    //控制器准备
    [self vcPrepare];
    
    //数据传输
    [self dataTransfer];
    
    //事件
    [self event];
}


/*
 *  事件
 */
-(void)event{
    /*
     *  设置密码
     */
    
    /** 开始输入：第一次 */
    @WeakObj(self)
    self.lockView.setPWBeginBlock = ^(){
        @StrongObj(self)
        [self.label showNormalMsg:CoreLockPWDTitleFirst];
    };
    
    /** 开始输入：确认 */
    self.lockView.setPWConfirmlock = ^(){
        @StrongObj(self)
        [self.label showNormalMsg:CoreLockPWDTitleConfirm];
    };
    
    
    /** 密码长度不够 */
    self.lockView.setPWSErrorLengthTooShortBlock = ^(NSUInteger currentCount){
      @StrongObj(self)
        [self.label showWarnMsg:[NSString stringWithFormat:@"请连接至少%@个点",@(CoreLockMinItemCount)]];
    };
    
    /** 两次密码不一致 */
    self.lockView.setPWSErrorTwiceDiffBlock = ^(NSString *pwd1,NSString *pwdNow){
        @StrongObj(self)
        [self.label showWarnMsg:CoreLockPWDDiffTitle];
        
        self.navigationItem.rightBarButtonItem = self.resetItem;
    };
    
    /** 第一次输入密码：正确 */
    self.lockView.setPWFirstRightBlock = ^(){
      @StrongObj(self)
        [self.label showNormalMsg:CoreLockPWDTitleConfirm];
    };
    
    /** 再次输入密码一致 */
    self.lockView.setPWTwiceSameBlock = ^(NSString *pwd){
      @StrongObj(self)
        [self.label showNormalMsg:CoreLockPWSuccessTitle];
        
        //存储密码
        [CoreArchive setStr:pwd key:CoreLockPWDKey];
        
        //禁用交互
        self.view.userInteractionEnabled = NO;
        
        if(self.successBlock != nil) {
            self.successBlock(self,pwd);
        }
        
        if(CoreLockTypeModifyPwd == _type){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    };
    
    
    
    /*
     *  验证密码
     */
    
    /** 开始 */
    self.lockView.verifyPWBeginBlock = ^(){
        @StrongObj(self)
        [self.label showNormalMsg:CoreLockVerifyNormalTitle];
    };
    
    /** 验证 */
    self.lockView.verifyPwdBlock = ^(NSString *pwd){
    @StrongObj(self)
        //取出本地密码
        NSString *pwdLocal = [CoreArchive strForKey:CoreLockPWDKey];
        
        BOOL res = [pwdLocal isEqualToString:pwd];
        
        if(res){//密码一致
            
            [self.label showNormalMsg:CoreLockVerifySuccesslTitle];
            
            if(CoreLockTypeVeryfiPwd == _type){
                
                //禁用交互
                self.view.userInteractionEnabled = NO;
                
            }else if (CoreLockTypeModifyPwd == _type){//修改密码
                
                [self.label showNormalMsg:CoreLockPWDTitleFirst];
                
                self.modifyCurrentTitle = CoreLockPWDTitleFirst;
            }
            
            if(CoreLockTypeVeryfiPwd == _type) {
                if(self.successBlock != nil) self.successBlock(self,pwd);
            }
            
        }else{//密码不一致
            
            [self.label showWarnMsg:CoreLockVerifyErrorPwdTitle];

        }
        
        return res;
    };
    
    
    
    /*
     *  修改
     */
    
    /** 开始 */
    self.lockView.modifyPwdBlock =^(){
      @StrongObj(self)
        [self.label showNormalMsg:self.modifyCurrentTitle];
    };
    
    
}






/*
 *  数据传输
 */
-(void)dataTransfer{
    
    [self.label showNormalMsg:self.msg];
    
    //传递类型
    self.lockView.type = self.type;
}







/*
 *  控制器准备
 */
-(void)vcPrepare{

    //设置背景色
    self.view.backgroundColor = CoreLockViewBgColor;
    
    [self label];
    [self lockView];
    
    [self addforgetBtnAndModifyBtn];
    
    //初始情况隐藏
    self.navigationItem.rightBarButtonItem = nil;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //默认标题
    self.modifyCurrentTitle = CoreLockModifyNormalTitle;
    
    //修改密码
    if(CoreLockTypeModifyPwd == _type) {
        self.actionView.hidden = YES;
        [self.actionView removeFromSuperview];
        if(_isDirectModify) return;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }
    
    //设置密码
    if (CoreLockTypeSetPwd == _type) {
        self.actionView.hidden = YES;
        self.msg = CoreLockPWDTitleFirst;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSetPwdAction)];
    }
    
    //验证密码
    if (CoreLockTypeVeryfiPwd == _type) {
        self.modifyBtn.hidden = YES;
        
        if (self.showVerifyCancelBtn) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelVerifyPwdAction)];
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
        
    }
    
    
    if(![self.class hasPwd]){
        [_modifyBtn removeFromSuperview];
    }
}

//取消设置密码
- (void)cancelSetPwdAction
{
    if (self.cancelSetPwdBlock) {
        self.cancelSetPwdBlock(self);
    }
}

//取消验证密码
- (void)cancelVerifyPwdAction
{
    if (self.cancelVerifyPwdBlock) {
        self.cancelVerifyPwdBlock(self);
    }
}

-(void)dismiss{
    [self dismiss:0];
}



/*
 *  密码重设
 */
-(void)setPwdReset{
    
    [self.label showNormalMsg:CoreLockPWDTitleFirst];
    
    //隐藏
    self.navigationItem.rightBarButtonItem = nil;
    
    //通知视图重设
    [self.lockView resetPwd];
}

/*
 *  是否有本地密码缓存？即用户是否设置过初始密码？
 */
+(BOOL)hasPwd{
    
    NSString *pwd = [CoreArchive strForKey:CoreLockPWDKey];
    
    return pwd !=nil;
}




/*
 *  展示设置密码控制器
 */
+(instancetype)showSettingLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC,NSString *pwd))successBlock CancelSetPwdBlock:(void (^)(CLLockVC *lockVC))cancelSetPwdBlock {
    
    CLLockVC *lockVC = [self lockVC:vc];
    
    lockVC.title = @"设置密码";
    
    lockVC.actionView.hidden = YES;
    
    //设置类型
    lockVC.type = CoreLockTypeSetPwd;
    
    //保存block
    lockVC.successBlock = successBlock;
    
    //取消设置密码
    lockVC.cancelSetPwdBlock = cancelSetPwdBlock;
    
    return lockVC;
}



/*
 *  展示验证密码输入框
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc forgetPwdBlock:(void(^)(CLLockVC *lockVC))forgetPwdBlock successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock{
    
    
    CLLockVC *lockVC = [self lockVC:vc];
    
    lockVC.title = @"手势解锁";
    
    //设置类型
    lockVC.type = CoreLockTypeVeryfiPwd;
    
    //保存block
    lockVC.successBlock = successBlock;
    lockVC.forgetPwdBlock = forgetPwdBlock;
    
    return lockVC;
}

/*
 *  展示验证密码输入框, 带有取消验证按钮的
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc forgetPwdBlock:(void(^)(CLLockVC *lockVC))forgetPwdBlock successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock cancelVerifyPwdBlock:(void(^)(CLLockVC *lockVC))cancelVerifyPwdBlock
{
    CLLockVC *lockVC = [self lockVC:vc];
    
    lockVC.title = @"手势解锁";
    
    lockVC.showVerifyCancelBtn = YES;
    
    //设置类型
    lockVC.type = CoreLockTypeVeryfiPwd;
    
    //保存block
    lockVC.successBlock = successBlock;
    lockVC.forgetPwdBlock = forgetPwdBlock;
    lockVC.cancelVerifyPwdBlock = cancelVerifyPwdBlock;
    
    return lockVC;
}



/*
 *  展示验证密码输入框
 */
+(instancetype)showModifyLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock{
    
    CLLockVC *lockVC = [self lockVC:vc];
    
    lockVC.title = @"修改密码";
    
    //设置类型
    lockVC.type = CoreLockTypeModifyPwd;
    
    //记录
    lockVC.successBlock = successBlock;
    
    return lockVC;
}





+(instancetype)lockVC:(UIViewController *)vc{
    
    CLLockVC *lockVC = [[CLLockVC alloc] init];

    lockVC.vc = vc;
    
    CLLockNavVC *navVC = [[CLLockNavVC alloc] initWithRootViewController:lockVC];
    
    [vc presentViewController:navVC animated:YES completion:nil];

    
    return lockVC;
}



-(void)setType:(CoreLockType)type{
    
    _type = type;
    
    //根据type自动调整label文字
    [self labelWithType];
}




/*
 *  根据type自动调整label文字
 */
-(void)labelWithType{
    
    if(CoreLockTypeSetPwd == _type){//设置密码
        
        self.msg = CoreLockPWDTitleFirst;
        
    }else if (CoreLockTypeVeryfiPwd == _type){//验证密码
        
        self.msg = CoreLockVerifyNormalTitle;
        
    }else if (CoreLockTypeModifyPwd == _type){//修改密码
        
        self.msg = CoreLockModifyNormalTitle;
    }
}




/*
 *  消失
 */
-(void)dismiss:(NSTimeInterval)interval{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


/*
 *  重置
 */
-(UIBarButtonItem *)resetItem{
    
    if(_resetItem == nil){
        //添加右按钮
        _resetItem= [[UIBarButtonItem alloc] initWithTitle:@"重设" style:UIBarButtonItemStylePlain target:self action:@selector(setPwdReset)];
    }
    
    return _resetItem;
}


//忘记密码
- (void)forgetBtnAction
{

    if(self.forgetPwdBlock != nil) {
        self.forgetPwdBlock(self);
        return;
    };
    [self dismiss:0];
}


//修改密码
- (void)modityBtnAction
{
    
    CLLockVC *lockVC = [[CLLockVC alloc] init];
    
    lockVC.title = @"修改密码";
    
    lockVC.isDirectModify = YES;
    
    //设置类型
    lockVC.type = CoreLockTypeModifyPwd;
    
    [self.navigationController pushViewController:lockVC animated:YES];
}












@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com