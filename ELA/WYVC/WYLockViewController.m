//
/*
 * Copyright (c) 2020 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#import "WYLockViewController.h"
#import "WYAuthViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface WYLockViewController ()

@property (nonatomic, strong) UIButton *buttonView;

@end

@implementation WYLockViewController

- (void)loadView {
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor clearColor];
    
    UILayoutGuide *margin = self.view.layoutMarginsGuide;
    
    self.buttonView = [[UIButton alloc] init];
    self.buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttonView setTitle:@"正在验证..." forState:UIControlStateNormal];
    [self.buttonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buttonView.titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    [self.buttonView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.buttonView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.buttonView.centerXAnchor constraintEqualToAnchor:margin.centerXAnchor],
        [self.buttonView.centerYAnchor constraintEqualToAnchor:margin.centerYAnchor constant:0.f],
        [self.buttonView.widthAnchor constraintEqualToAnchor:margin.widthAnchor multiplier:0.5f]
    ]];
    
    [self.buttonView addTarget:self action:@selector(authPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)authPressed:(UIButton *)sender {
    [self systemAuth];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackgroundImg:@"LimageEN"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self systemAuth];
}

- (void)systemAuth {
    [self.buttonView setTitle:@"正在验证..." forState:UIControlStateNormal];
    LAContext *authContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *authLocalizedReasonString = NSLocalizedString(@"手机用户验证", nil);
    if ([authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
        [authContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                  localizedReason:authLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
            if (success) {
                WYLog(@"=== Auth Success ===");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 0), dispatch_get_main_queue(), ^{
                    [self.buttonView setTitle:@"验证通过" forState:UIControlStateNormal];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 0), dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                });
            } else {
                WYLog(@"=== Auth Failed === : %@", error.localizedDescription);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 0), dispatch_get_main_queue(), ^{
                    [self.buttonView setTitle:@"验证失败" forState:UIControlStateNormal];
                    WYAuthViewController *authVC = [[WYAuthViewController alloc] init];
                    authVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:authVC animated:NO completion:nil];
                });
            }
        }];
    } else {
        WYLog(@"=== Cannot Auth === : %@", authError.localizedDescription);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:NO forKey:@"authOn"];
        [[FLTools share] showErrorInfo:NSLocalizedString(@"未设置系统锁屏密码", nil)];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
