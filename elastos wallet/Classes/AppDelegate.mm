/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  elastos wallet
//

#import "AppDelegate.h"
#import "FLFLTabBarVC.h"
#import "ELWalletManager.h"
#import "BaseNavigationVC.h"
#import "FLPrepareVC.h"
#import "FirstViewController.h"
#import "HMWFMDBManager.h"
#import "ELWalletManager.h"
#import "WOCrashProtectorManager.h"
#import "DAConfig.h"
#import <objc/runtime.h>
#import "HWMDIDManager.h"
#import "JWT.h"
#import "MyUtil.h"
#define KYRect  [UIScreen mainScreen].bounds
#import <UserNotifications/UserNotifications.h>
#import "IQKeyboardManager.h"
#import "WYCrashViewController.h"
#import "WYLockViewController.h"
#import "WYAuthViewController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL crashed = [prefs boolForKey:@"crashed"];
    NSString *crashReason = [prefs stringForKey:@"crashReason"];
    [prefs setBool:YES forKey:@"crashed"];
    [prefs setObject:@"Crashed Outside App" forKey:@"crashReason"];
    if (crashed) {
        WYLog(@"App Crashed Last Time: %@", crashReason);
    }
    
    //初始化一个imageView，并添加到window上
    [WYUtils setExceptionHandler];
    
    if(launchOptions[UIApplicationLaunchOptionsURLKey] != nil){
        [self application:application handleOpenURL:launchOptions[UIApplicationLaunchOptionsURLKey]];
    }
    
    
    
    NSString *languageString=[DAConfig userLanguage];
    
    if ([languageString  containsString:@"en"]) {
        [DAConfig setUserLanguage:@"en"];
        
    }else if ([languageString  containsString:@"zh"]){
        
        [DAConfig setUserLanguage:@"zh-Hans"];
        
    }else{
        
        [DAConfig setUserLanguage:@"en"];
    }
    
    self.window = [[UIWindow alloc]init];
    self.window.backgroundColor = [UIColor whiteColor];
    
    PluginResult *re=[[ELWalletManager share] getAllMasterWallets:nil];
    NSArray *reArray=re.message[@"success"];
    
    NSArray  *array =[[HMWFMDBManager sharedManagerType:walletType] allRecordWallet];
    if (array.count>reArray.count) {
        for (int i=0; i<array.count; i++) {
            FMDBWalletModel *model=[[FMDBWalletModel alloc]init];
            model=array[i];
            model.walletID=[NSString stringWithFormat:@"%@",model.walletID];
            BOOL isbool = [reArray containsObject: model.walletID];
            if (isbool==NO) {
                [[HMWFMDBManager sharedManagerType:walletType]delectRecordWallet: model];
            }
        }
    }else if(array.count<reArray.count){
        for (int i=0; i<reArray.count; i++) {
            FMDBWalletModel *model=[[FMDBWalletModel alloc]init];
            model.didString=@"";
            model.walletID=[NSString stringWithFormat:@"%@",reArray[i]];
            BOOL isbool = [array containsObject: model.walletID];
            if (isbool==NO) {
                model.walletName=@"null";
                sideChainInfoModel *sideModel=[[sideChainInfoModel alloc]init];
                sideModel.walletID=model.walletID;
                sideModel.sideChainName=@"ELA";
                sideModel.sideChainNameTime=@"--:--";
                sideModel.thePercentageMax=@"100";
                sideModel.thePercentageCurr=@"0";
                
                [[HMWFMDBManager sharedManagerType:sideChain] addsideChain:sideModel];
                [[HMWFMDBManager sharedManagerType:walletType]addWallet:model];
            }
        }
    }
    array =[[HMWFMDBManager sharedManagerType:walletType] allRecordWallet];
    
    if (crashed && CRASH_REPORT) {
        WYCrashViewController *vc = [[WYCrashViewController alloc] init];
        BaseNavigationVC *naVC = [[BaseNavigationVC alloc]initWithRootViewController:vc];
        self.window.rootViewController = naVC;
    } else {
        if (array.count==0) {
            FLPrepareVC *vc=[[FLPrepareVC alloc]init];
            BaseNavigationVC *naVC=[[BaseNavigationVC alloc]initWithRootViewController:vc];
            vc.type=creatWalletType;
            self.window.rootViewController = naVC;
        } else {
            [WYUtils setGlobal:@"APPStart" withValue:@YES];
            FLFLTabBarVC *tabVC = [[FLFLTabBarVC alloc]init];
            self.window.rootViewController = tabVC;
        }
    }
    
    [WOCrashProtectorManager makeAllEffective];
    UITableView.appearance.estimatedRowHeight = 0;
    UITableView.appearance.estimatedSectionFooterHeight = 0;
    UITableView.appearance.estimatedSectionHeaderHeight = 0;
    [self.window makeKeyAndVisible];
    
    if (@available(iOS 13.2, *)) {
        
    }else{
        const char *className = "_UITextLayoutView";
        Class cls = objc_getClass(className);
        if (cls == nil) {
            cls = objc_allocateClassPair([UIView class], className, 0);
            objc_registerClassPair(cls);
#if DEBUG
            printf("added %s dynamically\n", className);
#endif
        }
    }
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;//这个是点击空白区域键盘收缩的开关
    manager.enableAutoToolbar = NO;
    manager.keyboardDistanceFromTextField = 44;

    
    return YES;
    
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
      return UIInterfaceOrientationMaskPortrait;
    
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions{
    
    return YES;
    
}

-(void)applicationWillTerminate:(UIApplication *)application{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:NO forKey:@"crashed"];
    [prefs setObject:@"" forKey:@"crashReason"];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:NO forKey:@"crashed"];
    [prefs setObject:@"" forKey:@"crashReason"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"crashed"];
    [prefs setObject:@"Crashed Outside App" forKey:@"crashReason"];
}

/**
 iOS 9.0 以下 程序运行过程中调用
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    //WYLog(@"URL scheme:%@", [url scheme]);
    //WYLog(@"URL host:%@", [url host]);
    return YES;
}

/**
 iOS 9.0 之后 程序运行过程中调用
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options{
    
    //WYLog(@"URL scheme:%@", [url scheme]);
    //参数
    //WYLog(@"URL host:%@", [url host]);
    NSString *path = [url absoluteString];
    path = [path stringByRemovingPercentEncoding];
    NSMutableString *string = [[NSMutableString alloc] initWithString:path];
    
    BOOL sa= [MyUtil AddCommDIDWithJWT:string];
    NSString * message;
    if (sa) {
        message = @"保存成功";
    }else{
        message = @"保存失败";
    }
    [[FLTools share]showErrorInfo:message];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

-(void)applicationWillResignActive:(UIApplication *)application {
    [[ELWalletManager share]EMWMFlushData];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:NO forKey:@"crashed"];
    [prefs setObject:@"" forKey:@"crashReason"];
    
    [WYUtils setGlobal:@"InactiveStart" withValue:[NSDate date]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"crashed"];
    [prefs setObject:@"Crashed Outside App" forKey:@"crashReason"];
    [[ELWalletManager share]EMWMFlushData];
    
    BOOL authOn = [prefs boolForKey:@"authOn"];
    NSDate *inactiveStart = [WYUtils getGlobal:@"InactiveStart"];
    [WYUtils setGlobal:@"InactiveStart" withValue:nil];
    NSDate *inactiveEnd = [NSDate date];
    if (!inactiveStart) {
        inactiveStart = inactiveEnd;
    }
    NSTimeInterval inactiveTime = [inactiveEnd timeIntervalSinceDate:inactiveStart];
    WYLog(@"=== dev temp === Inactive time is: %f authOn is: %d", inactiveTime, authOn);
    if (inactiveTime > 60.f && authOn) {
        UIViewController *topVC = [WYUtils topViewController];
        WYLog(@"=== dev temp === Top Class is: %@", [topVC class]);
        if (!([topVC isKindOfClass:[WYLockViewController class]] || [topVC isKindOfClass:[WYAuthViewController class]])) {
            WYLockViewController *lockVC = [[WYLockViewController alloc] init];
            lockVC.modalPresentationStyle = UIModalPresentationFullScreen;
            WYLog(@"=== dev temp === Lock nav is: %@", topVC.navigationController);
            [topVC.navigationController presentViewController:lockVC animated:NO completion:nil];
        }
    }
}

-(void)regsLocaNotc{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *notiCenter = [UNUserNotificationCenter currentNotificationCenter];
        notiCenter.delegate = self;
    
           [notiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
               
           }];
           [notiCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
               
           }];
    } else {
        
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    
   UIApplication *app = [UIApplication sharedApplication];
   app.applicationIconBadgeNumber =0;
    completionHandler(UNNotificationPresentationOptionSound + UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
}
@end
