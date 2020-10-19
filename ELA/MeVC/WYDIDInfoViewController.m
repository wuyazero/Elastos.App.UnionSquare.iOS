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


#import "WYDIDInfoViewController.h"

@interface WYDIDInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *DIDAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *expireTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *customInfoTextField;

@end

@implementation WYDIDInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title = NSLocalizedString(@"名片信息", nil);
    
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"window_750_close"];
    
    self.nameTextField.enabled = NO;
    self.DIDAddressTextField.enabled = NO;
    self.expireTimeTextField.enabled = NO;
    self.birthDateTextField.enabled = NO;
    self.sexTextField.enabled = NO;
    self.twitterTextField.enabled = NO;
    self.customInfoTextField.enabled = NO;
    
    [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField: self.customInfoTextField withTxt:NSLocalizedString(@"自定义选项的内容文字", nil)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    [pStyle setAlignment:NSTextAlignmentRight];
    [pStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    if (self.model.didName) {
        self.nameTextField.text = self.model.didName;
    }
    if (self.model.didAddress) {
        NSMutableAttributedString *didText = [[NSMutableAttributedString alloc] initWithString:self.model.didAddress];
        [didText addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, didText.length)];
        self.DIDAddressTextField.attributedText = didText;
        //        self.DIDAddressTextField.text = self.model.didAddress;
    }
    if (self.model.expireTime) {
        self.expireTimeTextField.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"至", nil),[[FLTools share]YMDCommunityTimeConversionTimeFromTimesTamp:self.model.expireTime]];
    }
    if (self.model.birthDate) {
        self.birthDateTextField.text = self.model.birthDate;
    }
    if (self.model.sex) {
        self.sexTextField.text = self.model.sex;
    }
    if (self.model.twitter) {
        self.twitterTextField.text = self.model.twitter;
    }
    if (self.model.customInfo) {
        self.nameTextField.text = [[FLTools share] returnJSONStringWithDictionary:self.model.customInfo];
    }
}


- (IBAction)DIDCopyToClipboard:(id)sender {
    [[FLTools share]copiedToTheClipboardWithString:self.DIDAddressTextField.text];
}

- (void)setModel:(WYDIDChainInfoModel *) model{
    _model = model;
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
