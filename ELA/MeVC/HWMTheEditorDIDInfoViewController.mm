//
//  HWMTheEditorDIDInfoViewController.m
//  elastos wallet
//
//  Created by  on 2019/10/31.
//

#import "HWMTheEditorDIDInfoViewController.h"
#import "HWMDIDDataListView.h"
#import "HWMDIDManager.h"
#import "HMWpwdPopupView.h"
#import "HMWSendSuccessPopuView.h"
#import "ELWalletManager.h"
#import "HWMTransactionDetailsView.h"

@interface HWMTheEditorDIDInfoViewController ()<HWMDIDDataListViewDelegate,HMWpwdPopupViewDelegate,UITextFieldDelegate,HWMTransactionDetailsViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DIDTextInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *DIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *updatesButton;

@property(strong,nonatomic)HWMDIDDataListView *dataListView;
@property(strong,nonatomic)HMWSendSuccessPopuView *sendSuccessPopuV;
@property(strong,nonatomic)HWMTransactionDetailsView *transactionDetailsView;
@property(assign,nonatomic)double blance;
@end

@implementation HWMTheEditorDIDInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title=NSLocalizedString(@"编辑DID基本信息", nil);
    self.DIDTextInfoLabel.text=NSLocalizedString(@"DID信息", nil);
    [self.updatesButton setTitle:NSLocalizedString(@"更新发布", nil) forState:UIControlStateNormal];
    
  
    if (self.model.didName.length==0) {
        self.model.didName=@"unknown";
    }
    self.nickNameLabel.text=self.model.didName;
    self.nickNameLabel.delegate=self;
    self.publicKeyLabel.text=self.PubKeyString;
    self.DIDLabel.text=[NSString stringWithFormat:@"%@",self.model.did];
    self.timeDataLabel.text=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"有效期至 ", nil),[[FLTools share]YMDCommunityTimeConversionTimeFromTimesTamp:self.model.endString]];
    [self getBalance];
}
- (IBAction)changeTimeDataInfoEvent:(id)sender {
    UIView *mainView =  [self mainWindow];
    [mainView addSubview:self.dataListView];
    [self.dataListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(mainView);
    }];
    [self.view endEditing:YES];
}
- (IBAction)updatesEvent:(id)sender {
    [self.view endEditing:YES];
    if (self.model.didName.length==0) {
        [[FLTools share]showErrorInfo:NSLocalizedString(@"请输入姓名(必填)", nil)];
        return;
    }
    [self showPWDView];
}
//-(HMWpwdPopupView *)ShowPoPWDView{
//    if (!_ShowPoPWDView) {
//        _ShowPoPWDView =[[HMWpwdPopupView alloc]init];
//        _ShowPoPWDView.delegate=self;
//    }
//    return _ShowPoPWDView;
//}
-(HWMDIDDataListView *)dataListView{
    if (!_dataListView) {
        _dataListView =[[HWMDIDDataListView alloc]init];
        _dataListView.delegate=self;
        _dataListView.ListViewType=DIDDataType;
    }
    return _dataListView;
}

-(void)cancelDataListView{
    [self.dataListView removeFromSuperview];
    self.dataListView=nil;
}

-(void)selectDataWithYY:(NSString*_Nullable)yy withMM:(NSString*_Nullable)mm wihMMWithInt:(NSInteger)mInt wtihDD:(NSString*_Nullable)dd{
    
    self.model.endString=[[FLTools share]timeSwitchTimestamp:[NSString stringWithFormat:@"%@-%@-%@ 00:00:00",yy,mm,dd]];
    self.timeDataLabel.text=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"有效期至 ", nil),[[FLTools share]YMDCommunityTimeConversionTimeFromTimesTamp:self.model.endString]];
    [self cancelDataListView];
    
}
-(void)setModel:(HWMDIDInfoModel *)model{
    if (model==nil) {
        model =[[HWMDIDInfoModel alloc]init];
    }
    _model=model;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}


-(void)showPWDView{
    UIView *mainView =[self mainWindow];
    [mainView addSubview:self.transactionDetailsView];
    [self.transactionDetailsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(mainView);
    }];
    
}
-(void)showSendSuccessView{
    self.sendSuccessPopuV =[[HMWSendSuccessPopuView alloc]init];
    UIView *manView=[self mainWindow];
    [manView addSubview:self.sendSuccessPopuV];
    [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(manView);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendSuccessPopuV removeFromSuperview];
        self.sendSuccessPopuV=nil;
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [[FLTools share]textField:textField replacementString:string withStringLenth:50];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.model.didName=textField.text;
    
}
-(void)getBalance{
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,@"IDChain",@2] callbackId:self.currentWallet.walletID className:@"Wallet" methodName:@"getBalance"];
    PluginResult * result =[[ELWalletManager share]getBalance:mommand];
    
    NSString *status=[NSString stringWithFormat:@"%@",result.status];
    if ([status isEqualToString:@"1"]){
      NSString *blanceString=[[FLTools share] elaScaleConversionWith:[NSString stringWithFormat:@"%@",result.message[@"success"]]];
        self.blance=[blanceString doubleValue];
    }
}
-(HWMTransactionDetailsView *)transactionDetailsView{
    
    if (!_transactionDetailsView) {
        _transactionDetailsView =[[HWMTransactionDetailsView alloc]init];
        _transactionDetailsView.popViewTitle=NSLocalizedString(@"交易详情", nil);
        _transactionDetailsView.delegate=self;
        _transactionDetailsView.DetailsType=didInfoType;
        [_transactionDetailsView  TransactionDetailsWithFee:@"0.0002" withTransactionDetailsAumont:nil];
    }
    return _transactionDetailsView;
}
#pragma mark ---------HWMTransactionDetailsView----------
-(void)closeTransactionDetailsView{
    [self.transactionDetailsView removeFromSuperview];
    self.transactionDetailsView=nil;
}
-(void)pwdAndInfoWithPWD:(NSString*)pwd{
    [self.view endEditing:YES];
    if (self.blance<0.0001) {
        [[FLTools share]showErrorInfo:@"余额不足"];
        return;
    }
    self.model.didName=self.nickNameLabel.text;
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,pwd] callbackId:self.currentWallet.masterWalletID className:@"Wallet" methodName:@"ExportxPrivateKey"];
    NSString *  privatekeyString=[[ELWalletManager share]ExportxPrivateKey:mommand];
    if (privatekeyString.length==0) {
        return;
    }
    if (self.model.didName.length==0) {
        [[FLTools share]showErrorInfo:NSLocalizedString(@"请输入姓名(必填)", nil)];
        return;
    }
    
    [[HWMDIDManager shareDIDManager]hasDIDWithPWD:pwd withDIDString:self.model.did WithPrivatekeyString:@"" WithmastWalletID:self.currentWallet.masterWalletID needCreatDIDString:NO];
     self.model.editTime=[[FLTools share]getNowTimeTimestampS];
    if ([[HWMDIDManager shareDIDManager]updateInfoWithInfo:self.model]) {
        HWMDIDInfoModel *rdModel= [[HWMDIDManager shareDIDManager]readDIDCredential];
        [self closeTransactionDetailsView];
        rdModel.didName=self.model.didName;
        rdModel.endString=self.model.endString;
//        [[HWMDIDManager shareDIDManager]saveDIDCredentialWithDIDModel:rdModel];
        [self showSendSuccessView];
        
    }
    //    else{
    ////           [[FLTools share]showErrorInfo:@"失败"];
    //       }
}


@end
