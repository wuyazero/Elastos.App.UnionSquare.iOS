//
//  HWMAddPersonalInformationViewController.m
//  elastos wallet
//
//  Created by  on 2019/10/25.
//

#import "HWMAddPersonalInformationViewController.h"
#import "HWMCreateDIDListTableViewCell.h"
#import "HWMTheAreaCodeAndPhonenumberTableViewCell.h"
#import "HWMAddPersonalProfileViewController.h"
#import "HWMDIDDataListView.h"
#import "HMWSelectCountriesOrRegionsViewController.h"
#import "HMWFMDBManager.h"
#import "HMWToDeleteTheWalletPopView.h"
#import "ELWalletManager.h"
#import "HMWToDeleteTheWalletPopView.h"
#import "HMWAddTheCurrencyListViewController.h"
#import "HMWpwdPopupView.h"
#import "HWMDIDInfoListView.h"
#import "HWMDIDManager.h"
#import "HMWSendSuccessPopuView.h"
#import "HMWpwdPopupView.h"
#import "DAConfig.h"
#import "HWMConfidentialInformationViewController.h"
#import "HMWaddFooterView.h"
#import "HWMTransactionDetailsView.h"
#import "WYDIDCustomInfoTableViewCell.h"
#import "WYAddCustomContentViewController.h"
#import "WYSelectCustomTypeView.h"

UINib *_cellCreateDIDListNib;
UINib *_cellCodeAndPhonenumberNib;
static NSString *cellString=@"HWMCreateDIDListTableViewCell";
static NSString *cellCodeAndPhonenumberString=@"HWMTheAreaCodeAndPhonenumberTableViewCell";

static NSString  *customInfoString=@"WYDIDCustomInfoTableViewCell";

@interface HWMAddPersonalInformationViewController ()<UITableViewDelegate,UITableViewDataSource,HWMDIDDataListViewDelegate, HMWSelectCountriesOrRegionsViewControllerDelegate,HWMDIDInfoListViewDelegate,HWMCreateDIDListTableViewCellDelegate,UITextFieldDelegate,HWMTheAreaCodeAndPhonenumberTableViewCellDelegate,HMWpwdPopupViewDelegate,HMWToDeleteTheWalletPopViewDelegate,HMWaddFooterViewDelegate,HWMTransactionDetailsViewDelegate, WYDIDCustomInfoTableViewCellDelegate, WYSelectCustomTypeViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textInfoLabel;
/*
 *<# #>
 */
@property(strong,nonatomic)UIButton *skipButton;
/*
 *<# #>
 */
@property(strong,nonatomic)NSArray *dataSorse;
@property (weak, nonatomic) IBOutlet UITableView *table;
/*
 *<# #>
 */
@property(strong,nonatomic)HWMDIDDataListView *DIDDataListV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHeight;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWToDeleteTheWalletPopView *deleteHasSaveChainView;
/*
 *<# #>
 */
@property(strong,nonatomic)NSMutableArray*defMArray;
/*
 *<# #>
 */
@property(strong,nonatomic)NSArray*allInfoListArray;
/*
 *<# #>
 */
@property(strong,nonatomic)NSMutableArray*showInfoListAarry;
/*
 *<# #>
 */
@property(strong,nonatomic)HWMDIDInfoListView*showAllInfoView;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWSendSuccessPopuView*sendSuccessPopuV;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWpwdPopupView*pwdPopupV;
@property(copy,nonatomic)NSString* deleteIndex;

@property(assign,nonatomic)double blance;
@property(assign,nonatomic)BOOL needUpdate;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWaddFooterView *addFooterView;
/*
 *<# #>
 */
@property(strong,nonatomic)NSArray *allShowListArray;
/*
 *<# #>
 */
@property(strong,nonatomic)HWMTransactionDetailsView  *transactionDetailsView;

@property (strong, nonatomic) NSMutableDictionary *customInfosDic;
@property (strong, nonatomic) WYSelectCustomTypeView *typeSelectView;

@end

@implementation HWMAddPersonalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.skipButton];
    [self makeUI];
    self.blance=0.f;
    self.textInfoLabel.text=NSLocalizedString(@"温馨提示：本页内容均非必填，仅保存在本地，供用户授权使用。", nil);
    
    if (self.isChain) {
        self.textInfoLabel.text=NSLocalizedString(@"本页面内容均非必填，且将作为DID信息发布上链并完全公开。请注意隐私保护，谨慎填写。", nil);
    }
    
    self.needUpdate=NO;
    if (self.isEidet||self.whereFrome) {
        if (self.isEidet) {
            self.title=NSLocalizedString(@"编辑个人信息", nil);
            if (self.isChain) {
                self.title = NSLocalizedString(@"编辑DID信息", nil);
            }
        }
        
        if (self.whereFrome==YES) {
            self.title=NSLocalizedString(@"添加个人信息", nil);
            if (self.isChain) {
                self.title = NSLocalizedString(@"添加DID信息", nil);
            }
        }
        [self.skipButton setTitle:NSLocalizedString(@"保存", nil) forState: UIControlStateNormal];
        if (self.isChain) {
            [self.skipButton setTitle:NSLocalizedString(@"发布", nil) forState: UIControlStateNormal];
        }
        if (self.isEidet) {
            [self updaeDataArray];
        }
    }else{
        self.title=NSLocalizedString(@"添加个人信息", nil);
        if (self.isChain) {
            self.title = NSLocalizedString(@"添加DID信息", nil);
        }
    }
    NSString *languageString=[DAConfig userLanguage];
    if ([languageString  containsString:@"en"]) {
        self.infoHeight.constant=45.f;
    }
    [self getBalance];
}
-(void)updaeDataArray{
    [self.defMArray removeAllObjects];
    [self.showInfoListAarry removeAllObjects];
    NSString *indexString;
    if (self.model.nickname.length>0) {
        indexString=self.allInfoListArray[0][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"0"];
    }
    if (self.model.gender.length>0) {
        indexString=self.allInfoListArray[1][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"1"];
    }
    if (self.model.birthday.length>0) {
        indexString=self.allInfoListArray[2][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"2"];
    }
    if (self.model.avatar.length>0) {
        indexString=self.allInfoListArray[3][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"3"];
    }
    if (self.model.email.length>0) {
        indexString=self.allInfoListArray[4][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"4"];
    }
    if (self.model.phone.length>0) {
        indexString=self.allInfoListArray[5][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"5"];
    }
    if (self.model.nation.length>0) {
        indexString=self.allInfoListArray[6][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"6"];
    }
    if (self.model.introduction.length>0) {
        indexString=self.allInfoListArray[7][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"7"];
    }
    if (self.model.homePage.length>0) {
        indexString=self.allInfoListArray[8][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"8"];
    }
    if (self.model.facebook.length>0) {
        indexString=self.allInfoListArray[9][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"9"];
    }
    if (self.model.twitter.length>0) {
        indexString=self.allInfoListArray[10][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"10"];
    }
    if (self.model.weibo.length>0) {
        indexString=self.allInfoListArray[11][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"11"];
    }
    if (self.model.wechat.length>0) {
        indexString=self.allInfoListArray[12][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"12"];
    }
    if (self.model.googleAccount.length>0) {
        indexString=self.allInfoListArray[13][@"index"];
        [self.defMArray addObject:indexString];
    }else{
        [self.showInfoListAarry addObject:@"13"];
    }
    
    WYLog(@"=== dev temp === self.model.customInfos: %@ length %ld", self.model.customInfos, self.model.customInfos.length);
    
    if (self.model.customInfos.length>0) {
        NSDictionary *customInfosList = [WYUtils dicFromJSONString:self.model.customInfos];
        NSInteger next = 0;
        self.customInfosDic = [[NSMutableDictionary alloc] init];
        for (NSDictionary *customInfo in customInfosList) {
            next++;
            NSInteger index = next;
            if ([customInfo[@"type"] isEqualToString:@"-1"]) {
                index += 2000000;
            } else if ([customInfo[@"type"] isEqualToString:@"-2"]) {
                index += 3000000;
            }
            NSString *indexStr = [NSString stringWithFormat:@"%ld", index];
            [self.defMArray addObject:indexStr];
            self.customInfosDic[indexStr] = customInfo;
        }
    }
    
    if (self.customInfosDic.count < 5) {
        [self.showInfoListAarry addObject:@"14"];
    }
    
    if (self.defMArray.count==self.allInfoListArray.count) {
        self.addFooterView.alpha=0.f;
    }
    
    [self.table reloadData];
}


- (NSMutableDictionary *)customInfosDic {
    if (!_customInfosDic) {
        _customInfosDic = [[NSMutableDictionary alloc] init];
    }
    return _customInfosDic;
}

- (WYSelectCustomTypeView *)typeSelectView {
    if (!_typeSelectView) {
        _typeSelectView = [[WYSelectCustomTypeView alloc] init];
        _typeSelectView.translatesAutoresizingMaskIntoConstraints = NO;
        _typeSelectView.delegate = self;
    }
    return _typeSelectView;
}

-(NSMutableArray *)defMArray{
    if (!_defMArray) {
        _defMArray=[NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"7",@"8",@"9",@"12"]];
    }
    return _defMArray;
}
-(NSMutableArray *)showInfoListAarry{
    if (!_showInfoListAarry) {
        _showInfoListAarry=[NSMutableArray arrayWithArray:@[@"0",@"5",@"6",@"10",@"11",@"13", @"14"]];
    }
    return _showInfoListAarry;
}
-(HWMDIDInfoListView *)showAllInfoView{
    if (!_showAllInfoView) {
        _showAllInfoView=[[HWMDIDInfoListView alloc]init];
        _showAllInfoView.delegate=self;
    }
    return _showAllInfoView;
}
-(NSArray *)allInfoListArray{
    if (!_allInfoListArray) {
        _allInfoListArray = @[
        @{@"text":NSLocalizedString(@"昵称", nil),@"index":@"0",@"type":@"1"},@{@"text":NSLocalizedString(@"性别",nil),@"index":@"1",@"type":@"2"},@{@"text":NSLocalizedString(@"出生日期",nil),@"index":@"2",@"type":@"2"},@{@"text":NSLocalizedString(@"头像url",nil),@"index":@"3",@"type":@"1"},@{@"text":NSLocalizedString(@"邮箱",nil),@"index":@"4",@"type":@"1"},@{@"text":NSLocalizedString(@"手机号", nil) ,@"index":@"5",@"type":@"3"},@{@"text":NSLocalizedString(@"国家/地区", nil),@"index":@"6",@"type":@"2"},@{@"text":NSLocalizedString(@"个人简介qe",nil),@"index":@"7",@"type":@"4"},@{@"text":NSLocalizedString(@"个人主页网址",nil),@"index":@"8",@"type":@"1"},@{@"text":NSLocalizedString(@"Facebook账号",nil),@"index":@"9",@"type":@"1"},@{@"text":NSLocalizedString(@"Twitter账号",nil),@"index":@"10",@"type":@"1"},@{@"text":NSLocalizedString(@"微博账号",nul),@"index":@"11",@"type":@"1"},@{@"text":NSLocalizedString(@"微信账号",null),@"index":@"12",@"type":@"1"},
        @{@"text":NSLocalizedString(@"谷歌账号1",null),@"index":@"13",@"type":@"1"},
        @{@"text":NSLocalizedString(@"自定义信息",null),@"index":@"14",@"type":@"666"}
        ];
    }
    return _allInfoListArray;
    
}
-(NSArray *)allShowListArray{
    if (!_allShowListArray) {
        _allShowListArray = @[
        @{@"text":NSLocalizedString(@"昵称", nil),@"index":@"0",@"type":@"1"},@{@"text":NSLocalizedString(@"性别",nil),@"index":@"1",@"type":@"2"},@{@"text":NSLocalizedString(@"出生日期",nil),@"index":@"2",@"type":@"2"},@{@"text":NSLocalizedString(@"头像url1",nil),@"index":@"3",@"type":@"1"},@{@"text":NSLocalizedString(@"邮箱1",nil),@"index":@"4",@"type":@"1"},@{@"text":NSLocalizedString(@"手机号", nil) ,@"index":@"5",@"type":@"3"},@{@"text":NSLocalizedString(@"国家/地区1", nil),@"index":@"6",@"type":@"2"},@{@"text":NSLocalizedString(@"个人简介qe",nil),@"index":@"7",@"type":@"4"},@{@"text":NSLocalizedString(@"个人主页网址1",nil),@"index":@"8",@"type":@"1"},@{@"text":NSLocalizedString(@"Facebook账号",nil),@"index":@"9",@"type":@"1"},@{@"text":NSLocalizedString(@"Twitter账号",nil),@"index":@"10",@"type":@"1"},@{@"text":NSLocalizedString(@"微博账号",nul),@"index":@"11",@"type":@"1"},@{@"text":NSLocalizedString(@"微信账号",null),@"index":@"12",@"type":@"1"},
        @{@"text":NSLocalizedString(@"谷歌账号",null),@"index":@"13",@"type":@"1"},
        @{@"text":NSLocalizedString(@"自定义信息",null),@"index":@"14",@"type":@"666"}
        ];
    }
    return _allShowListArray;
    
}
-(void)makeUI{
    
    
    _cellCreateDIDListNib=[UINib nibWithNibName:cellString bundle:nil];
    _cellCodeAndPhonenumberNib=[UINib nibWithNibName:cellCodeAndPhonenumberString bundle:nil];
    [self.table registerNib:_cellCreateDIDListNib forCellReuseIdentifier:cellString];
    [self.table registerNib:_cellCodeAndPhonenumberNib forCellReuseIdentifier:cellCodeAndPhonenumberString];
    [self.table registerClass:[WYDIDCustomInfoTableViewCell
                               class] forCellReuseIdentifier:customInfoString];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.rowHeight = 55;
    self.table.delegate =self;
    self.table.dataSource =self;
    self.table.backgroundColor=[UIColor clearColor];
    self.table.userInteractionEnabled=YES;
    self.table.contentSize = CGSizeMake(0,1000);
    UIView *headView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, 162)];
    headView.userInteractionEnabled=YES;
    [headView addSubview:self.addFooterView];
    self.table.tableFooterView =headView;
}
-(UIButton *)skipButton{
    if (!_skipButton) {
        _skipButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_skipButton setTitle:NSLocalizedString(@"发布", nil) forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipButton.titleLabel.font=[UIFont systemFontOfSize:14];
        [_skipButton addTarget:self action:@selector(skipVCEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (void)skipVCEvent{
    [self.view endEditing:YES];
    
    NSMutableArray *customInfosArr = [[NSMutableArray alloc] init];
    
    [self bubblingSort:self.defMArray];
    for (NSString *index in self.defMArray) {
        if ([index intValue] > 1000000 && self.customInfosDic[index]) {
            NSDictionary *customInfo = self.customInfosDic[index];
            NSString *customType = customInfo[@"type"];
            NSString *customTitle = [customInfo[@"title"] stringByTrim];
            NSString *customContent = [customInfo[@"content"] stringByTrim];
            
            if (customType.length > 0 && customTitle.length > 0 && customContent.length > 0) {
                [customInfosArr addObject:self.customInfosDic[index]];
            }
        }
    }
    
    WYLog(@"=== dev temp === customInfosArr: %@", customInfosArr);
    
    if (customInfosArr.count > 0) {
        NSString *customInfosJSON = [WYUtils arrToJSONString:customInfosArr];
        WYLog(@"=== dev temp === customInfosJSON: %@", customInfosJSON);
        self.model.customInfos = customInfosJSON;
    } else {
        self.model.customInfos = @"";
    }
    
    
    WYLog(@"=== dev temp === Skip Button: isEidet %d whereFrome %d isChain %d", self.isEidet, self.whereFrome, self.isChain);
    
    if (self.isChain) {
        [self showPWDView];
    } else if (self.isEidet||self.whereFrome) {
        
        UIView *manView=[self mainWindow];
        [manView addSubview:self.pwdPopupV];
        [self.pwdPopupV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(manView);
        }];
    } else {
        UIView *manView=[self mainWindow];
        [manView addSubview:self.transactionDetailsView];
        [self.transactionDetailsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(manView);
        }];
    }
}

- (void)showPWDView {
    UIView *mainView =[self mainWindow];
    [mainView addSubview:self.transactionDetailsView];
    [self.transactionDetailsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(mainView);
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isEidet) {
        NSString *indexString=self.defMArray[indexPath.row];
        NSInteger indexValue = [indexString integerValue];
        if (indexValue > 1000000) {
            indexValue = 14;
        }
        NSDictionary *infDic=self.allShowListArray[indexValue];
        NSString *titleString=infDic[@"text"];
        NSString *typeString=infDic[@"type"];
        
        if([typeString isEqualToString:@"3"]) {
            HWMTheAreaCodeAndPhonenumberTableViewCell *cell=[_cellCodeAndPhonenumberNib instantiateWithOwner:nil options:nil][0]; cell.MobilePhoneTextField.placeholder=NSLocalizedString(@"请输入手机号", nil);
            cell.MobilePhoneTextField.text=self.model.phone;
            cell.MobilePhoneTextField.tag=10001;
            cell.theArNumberTextField.leftViewMode = UITextFieldViewModeAlways;
            cell.MobilePhoneTextField.leftViewMode = UITextFieldViewModeAlways;
            cell.MobilePhoneTextField.textAlignment=NSTextAlignmentRight;
            cell.theArNumberTextField.textAlignment=NSTextAlignmentRight;
            cell.dic=infDic;
            cell.index = indexString;
            cell.delegate=self;
            [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:cell.MobilePhoneTextField withTxt:NSLocalizedString(@"请输入手机号", nil)];
            cell.theArNumberTextField.tag=10002;
            if (self.model.phoneCode.length>0) {
                cell.theArNumberTextField.text=self.model.phoneCode;
            }
            cell.theArNumberTextField.delegate=self;
            cell.MobilePhoneTextField.delegate=self;
            [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField: cell.theArNumberTextField withTxt:NSLocalizedString(@"请输入区号", nil)];
            return cell;
            
        }
        
        if ([typeString isEqualToString:@"666"]) {
            WYDIDCustomInfoTableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:customInfoString];
            cell.delegate = self;
            cell.index = indexString;
            cell.cellType = @"-1";
            if ([indexString intValue] > 3000000) {
                cell.cellType = @"-2";
            }
            cell.cellTitle.text = @"";
            cell.cellContent.text = @"";
            cell.cellStore.text = @"";
            
            if (self.customInfosDic[indexString]) {
                NSDictionary *infoDic = self.customInfosDic[indexString];
                NSString *cellType = infoDic[@"type"];
                if (cellType.length > 0) {
                    cell.cellType = cellType;
                    cell.cellTitle.text = infoDic[@"title"];
                    cell.cellContent.text = infoDic[@"content"];
                    cell.cellStore.text = infoDic[@"content"];
                }
            }
            
            [cell reloadData];
            return cell;
        }
        
        HWMCreateDIDListTableViewCell *cell =
        [_cellCreateDIDListNib instantiateWithOwner:nil options:nil][0];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.arrowImageView.alpha=1.f;
        cell.index=indexString;
        cell.infoLabel.text=titleString;
        cell.isEeiD=YES;
        cell.delegate=self;
        if ([typeString isEqualToString:@"2"]) {
            cell.intPutTextField.enabled=NO;
            if ([indexString integerValue]==1&&self.model.gender.length>0) {
                cell.intPutTextField.text=[[FLTools share]genderStringWithType:self.model.gender];
            }else if ([indexString integerValue]==2&&self.model.birthday.length>0){
                cell.intPutTextField.text=[[FLTools share]TimeFormatConversionBirthday: self.model.birthday];
            }else if ([indexString integerValue]==6&&self.model.nation.length>0){
                if (self.model.nation.length>0) {
                    cell.intPutTextField.text=[[FLTools share]contryNameTransLateByCode:[self.model.nation integerValue]];
                }
            }
        }else if([typeString isEqualToString:@"4"]){
            cell.intPutTextField.alpha=0.f;
            if (self.model.introduction.length>0||self.needUpdate) {
                cell.LimitThatLabel.alpha=1.f;
                cell.LimitThatLabel.text=self.model.introduction;
            }else{
                cell.LimitThatLabel.alpha=0.f;
            }
            
        }else if([typeString isEqualToString:@"1"]){
            cell.intPutTextField.tag=100+[indexString integerValue];
            cell.intPutTextField.delegate=self;
            if ([titleString isEqualToString:NSLocalizedString(@"邮箱1", nil)]) {
                if (self.model.email.length>0) {
                    cell.intPutTextField.text=self.model.email;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"个人主页网址1", nil)]) {
                if (self.model.homePage.length>0) {
                    cell.intPutTextField.text=self.model.homePage;
                }
                
            }else if ([titleString isEqualToString:NSLocalizedString(@"Facebook账号", nil)]) {
                if (self.model.facebook.length>0) {
                    cell.intPutTextField.text=self.model.facebook;
                }
                
            }else if([titleString isEqualToString:NSLocalizedString(@"昵称", nil)]){
                if (self.model.nickname.length>0) {
                    cell.intPutTextField.text=self.model.nickname;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"头像url1", nil)]){
                if (self.model.avatar.length>0) {
                    cell.intPutTextField.text=self.model.avatar;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"Twitter账号", nil)]){
                if (self.model.twitter.length>0) {
                    cell.intPutTextField.text=self.model.twitter;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"微博账号", nil)]){
                if (self.model.weibo.length>0) {
                    cell.intPutTextField.text=self.model.weibo;
                }
                
            }else if ([titleString isEqualToString:NSLocalizedString(@"谷歌账号", nil)]){
                if (self.model.googleAccount.length>0) {
                    cell.intPutTextField.text=self.model.googleAccount;
                }
                
            }else if ([titleString isEqualToString:NSLocalizedString(@"微信账号", nil)]){
                if (self.model.wechat.length>0) {
                    cell.intPutTextField.text=self.model.wechat;
                    
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"自定义信息", nil)]){
                if (self.model.customInfos.length>0) {
                    cell.intPutTextField.text=self.model.customInfos;
                    
                }
            }
        }
        return cell;
    }else{
        NSString *indexString=self.defMArray[indexPath.row];
        NSInteger indexValue = [indexString integerValue];
        if (indexValue > 1000000) {
            indexValue = 14;
        }
        NSDictionary *infDic=self.allShowListArray[indexValue];
        NSString *titleString=infDic[@"text"];
        NSString *typeString=infDic[@"type"];
        if([typeString isEqualToString:@"3"]) {
            HWMTheAreaCodeAndPhonenumberTableViewCell *cell=[_cellCodeAndPhonenumberNib instantiateWithOwner:nil options:nil][0]; cell.MobilePhoneTextField.placeholder=NSLocalizedString(@"请输入手机号", nil);
            cell.MobilePhoneTextField.text=self.model.phone;
            cell.MobilePhoneTextField.tag=10001;
            cell.dic=infDic;
            cell.index = indexString;
            cell.delegate=self;
            [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:cell.MobilePhoneTextField withTxt:NSLocalizedString(@"请输入手机号", nil)];
            //        cell.theArNumberTextField.placeholder=NSLocalizedString(@"请输入区号(如+86)", nil);
            cell.theArNumberTextField.tag=10002;
            if (self.model.phoneCode.length>0) {
                cell.theArNumberTextField.text=self.model.phoneCode;
            }
            cell.theArNumberTextField.delegate=self;
            cell.MobilePhoneTextField.delegate=self;
            [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField: cell.theArNumberTextField withTxt:NSLocalizedString(@"请输入区号", nil)];
            return cell;
            
        }
        
        if ([typeString isEqualToString:@"666"]) {
            WYDIDCustomInfoTableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:customInfoString];
            cell.delegate = self;
            cell.index = indexString;
            cell.cellType = @"-1";
            if ([indexString intValue] > 3000000) {
                cell.cellType = @"-2";
            }
            cell.cellTitle.text = @"";
            cell.cellContent.text = @"";
            cell.cellStore.text = @"";
            
            if (self.customInfosDic[indexString]) {
                NSDictionary *infoDic = self.customInfosDic[indexString];
                NSString *cellType = infoDic[@"type"];
                if (cellType.length > 0) {
                    cell.cellType = cellType;
                    cell.cellTitle.text = infoDic[@"title"];
                    cell.cellContent.text = infoDic[@"content"];
                    cell.cellStore.text = infoDic[@"content"];
                }
            }
            
            [cell reloadData];
            return cell;
        }
        
        HWMCreateDIDListTableViewCell *cell =
        [_cellCreateDIDListNib instantiateWithOwner:nil options:nil][0];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.arrowImageView.alpha=1.f;
        cell.index=indexString;
        cell.delegate=self;
        if ([typeString isEqualToString:@"2"]) {
            cell.infoLabel.alpha=1.f;
            cell.infoLabel.text= [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"请选择", nil),titleString];
            cell.intPutTextField.alpha=0.f;
            if ([indexString integerValue]==1) {
                if (self.model.gender.length>0) {
                    cell.infoLabel.text=[[FLTools share]genderStringWithType:self.model.gender];
                }else{
                    cell.infoLabel.text= [NSString stringWithFormat:@"%@",titleString];
                }
                
            }else if ([indexString integerValue]==2){
                if (self.model.birthday.length>0) {
                    cell.infoLabel.text=[[FLTools share]TimeFormatConversionBirthday: self.model.birthday];
                }else{
                    cell.infoLabel.text= [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"请输入", nil),titleString];
                    
                }
                
                
            }else if ([indexString integerValue]==6){
                if (self.model.nation.length>0) {
                    cell.infoLabel.text=[[FLTools share]contryNameTransLateByCode:[self.model.nation integerValue]];
                }else{
                    
                }
            }
            
        }else if([typeString isEqualToString:@"4"]){
            cell.infoLabel.alpha=1.f;
            cell.infoLabel.text=[NSString stringWithFormat:@"%@",titleString];
            cell.intPutTextField.alpha=0.f;
            if (self.model.introduction.length>0||self.needUpdate) {
                cell.LimitThatLabel.alpha=1.f;
                cell.LimitThatLabel.text=self.model.introduction;
            }else{
                cell.LimitThatLabel.alpha=0.f;
            }
            
        }else if([typeString isEqualToString:@"1"]){
            cell.infoLabel.alpha=0.f;
            cell.intPutTextField.alpha=1.f;
            NSString *placeString=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"请输入", nil),titleString];
            cell.intPutTextField.placeholder=placeString;
            [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:cell.intPutTextField withTxt:placeString];
            cell.intPutTextField.tag=100+[indexString integerValue];
            cell.intPutTextField.delegate=self;
            if ([titleString isEqualToString:NSLocalizedString(@"邮箱", nil)]) {
                if (self.model.email.length>0) {
                    cell.intPutTextField.text=self.model.email;
                }
                
            }else if ([titleString isEqualToString:NSLocalizedString(@"个人主页网址", nil)]) {
                if (self.model.homePage.length>0) {
                    cell.intPutTextField.text=self.model.homePage;
                }
                
            }else if ([titleString isEqualToString:NSLocalizedString(@"Facebook账号", nil)]) {
                if (self.model.facebook.length>0) {
                    cell.intPutTextField.text=self.model.facebook;
                }
                
            }else if([titleString isEqualToString:NSLocalizedString(@"昵称", nil)]){
                if (self.model.nickname.length>0) {
                    cell.intPutTextField.text=self.model.nickname;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"头像url", nil)]){
                if (self.model.avatar.length>0) {
                    cell.intPutTextField.text=self.model.avatar;
                }else{
                    NSString *placeString=[NSString stringWithFormat:@"%@",titleString];
                    cell.intPutTextField.placeholder=placeString;
                    [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:cell.intPutTextField withTxt:placeString];
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"Twitter账号", nil)]){
                if (self.model.twitter.length>0) {
                    cell.intPutTextField.text=self.model.twitter;
                }
            }else if ([titleString isEqualToString:NSLocalizedString(@"微博账号", nil)]){
                if (self.model.weibo.length>0) {
                    cell.intPutTextField.text=self.model.weibo;
                }
                
            } else if ([titleString isEqualToString:NSLocalizedString(@"谷歌账号1", nil)]) {
                if (self.model.googleAccount.length>0) {
                    cell.intPutTextField.text=self.model.googleAccount;
                    
                }
                
            } else if ([titleString isEqualToString:NSLocalizedString(@"微信账号", nil)]) {
                if (self.model.wechat.length>0) {
                    cell.intPutTextField.text=self.model.wechat;
                    
                }
                
            } else if ([titleString isEqualToString:NSLocalizedString(@"自定义信息", nil)]) {
                if (self.model.customInfos.length>0) {
                    cell.intPutTextField.text=self.model.customInfos;
                    
                }
                
            }
        }
        return cell;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.defMArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indeString=self.defMArray[indexPath.row];
    [self.view endEditing:YES];
    
    if ([indeString isEqualToString:@"1"]) {//性别
        self.DIDDataListV.ListViewType=genderType;
        UIView *mainView = [self mainWindow];
        [mainView addSubview:self.DIDDataListV];
        [self.DIDDataListV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(mainView);
        }];
    } else if ([indeString isEqualToString:@"2"]) {//出生
        self.DIDDataListV.ListViewType=birthdayType;
        UIView *mainView = [self mainWindow];
        [mainView addSubview:self.DIDDataListV];
        [self.DIDDataListV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(mainView);
        }];
    } else if ([indeString isEqualToString:@"6"]) {
        HMWSelectCountriesOrRegionsViewController *SelectCountriesOrRegionsVC=[[HMWSelectCountriesOrRegionsViewController alloc]init];
        SelectCountriesOrRegionsVC.delegate=self;
        [self.navigationController pushViewController:SelectCountriesOrRegionsVC animated:YES];
    } else if ([indeString isEqualToString:@"7"]) {
        HWMAddPersonalProfileViewController *AddPersonalProfileVC=[[HWMAddPersonalProfileViewController alloc]init];
        AddPersonalProfileVC.model=self.model;
        AddPersonalProfileVC.isEidet=NO;
        __weak __typeof__ (self) weakSelf = self;
        AddPersonalProfileVC.block = ^(HWMDIDInfoModel * _Nonnull model) {
            weakSelf.model=model;
            weakSelf.needUpdate=YES;
            [weakSelf.table reloadData];
        };
        [self.navigationController pushViewController:AddPersonalProfileVC animated:YES];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (IBAction)nextAndSkipEvent:(id)sender {
    NSMutableArray  *nextArr=[[NSMutableArray alloc]init];
    if (self.showInfoListAarry.count>0) {
        self.showInfoListAarry=[self bubblingSort:self.showInfoListAarry];
        for (NSString *index in self.showInfoListAarry) {
            [nextArr addObject:self.allShowListArray[[index intValue]]];
        }
    }
    UIView *mainView =[self mainWindow];
    self.showAllInfoView.dataSourceArray=nextArr;
    [mainView addSubview:self.showAllInfoView];
    [self.showAllInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(mainView);
    }];
}

-(void)setModel:(HWMDIDInfoModel *)model{
    _model=model;
}

-(HWMDIDDataListView *)DIDDataListV{
    if (!_DIDDataListV) {
        _DIDDataListV =[[HWMDIDDataListView alloc]init];
        _DIDDataListV.delegate=self;
    }
    return _DIDDataListV;
}

- (void)cancelDataListView {
    [self.DIDDataListV removeFromSuperview];
    self.DIDDataListV=nil;
}

-(void)selectGender:(NSUInteger)genderType{
    self.model.gender=[NSString stringWithFormat:@"%lu",((unsigned long)genderType+1)];
    [self.table reloadData];
    [self cancelDataListView];
}

-(void)selectDataWithYY:(NSString *)yy withMM:(NSString *)mm wihMMWithInt:(NSInteger)mInt wtihDD:(NSString *)dd{
    self.model.birthday=[[FLTools share]timeSwitchTimestamp:[NSString stringWithFormat:@"%@-%@-%@ 00:00:00",yy,mm,dd]];
    [self.table reloadData];
    [self cancelDataListView];
}

-(void)selectTheCountryAreasModel:(NSDictionary*)modelDic{
    self.model.nation= modelDic[@"mobileCode"];
    [self.table reloadData];
}
-(void)setIsEidet:(Boolean)isEidet{
    _isEidet=isEidet;
}
-(void)addInfoWithIndex:(NSString *)index{
    NSString *indeString=[NSString stringWithFormat:@"%@",index];
    if (![self.defMArray containsObject:indeString]) {
        [self.defMArray addObject:indeString];
    }
    [self.showInfoListAarry removeObject:indeString];
    if (self.showInfoListAarry.count==0) {
        self.addFooterView.alpha=0.f;
    }
}
- (void)closeView{
    [self.showAllInfoView removeFromSuperview];
    if (self.defMArray.count>0) {
        self.defMArray=[self bubblingSort:self.defMArray];
    }
    
    [self.table reloadData];
}

- (void)addCustomInfo {
    UIView *mainView =[self mainWindow];
    [mainView addSubview:self.typeSelectView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.typeSelectView.topAnchor constraintEqualToAnchor:mainView.topAnchor],
        [self.typeSelectView.bottomAnchor constraintEqualToAnchor:mainView.bottomAnchor],
        [self.typeSelectView.leadingAnchor constraintEqualToAnchor:mainView.leadingAnchor],
        [self.typeSelectView.trailingAnchor constraintEqualToAnchor:mainView.trailingAnchor]
    ]];
}

- (void)addCustomType:(NSString *)customType {
    NSInteger next = 1;
    if (self.defMArray.count>0) {
        self.defMArray=[self bubblingSort:self.defMArray];
        NSInteger current = [self.defMArray[self.defMArray.count - 1] intValue];
        if (current > 1000000) {
            next = current % 1000000 + 1;
        }
    }
    NSInteger typeNum = 2000000;
    
    if ([customType isEqualToString:@"-2"]) {
        typeNum = 3000000;
    }
    
    NSString *indexString = [NSString stringWithFormat:@"%ld", typeNum + next];
    if (![self.defMArray containsObject:indexString]) {
        [self.defMArray addObject:indexString];
    }
    
    self.customInfosDic[indexString] = @{
        @"type": @"",
        @"title": @"",
        @"content": @""
    };
    
    if (self.customInfosDic.count >= 5) {
        [self.showInfoListAarry removeObject:@"14"];
    }
    
    [self.table reloadData];
}

- (void)customInfoMultiPressed:(NSString *)title withContent:(NSString *)currentContent withNextBlock:(void (^) (NSString *newContent))block {
    WYAddCustomContentViewController *contentVC = [[WYAddCustomContentViewController alloc] init];
    contentVC.title = title;
    contentVC.contentText = currentContent;
    contentVC.nextBlock = block;
    [contentVC refreshData];
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (void)updateCustomInfosDic:(NSString *)index withDic:(NSDictionary *)infoDic {
    self.customInfosDic[index] = infoDic;
    WYLog(@"=== dev temp === customInfosDic: %@", self.customInfosDic);
}

-(void)deleteWithIndex:(NSString*_Nullable)index{
    self.deleteIndex=index;
    if (self.whereFrome||self.isEidet) {
        if (self.noAleart) {
            [self delegateInfo];
        }else{
            [self showDeleteHasSaveChainView];
        }
    }else{
        [self delegateInfo];
    }
    
}
-(void)delegateInfo{
    
    NSString *indeString=[NSString stringWithFormat:@"%@",self.deleteIndex];
    if ([self.defMArray containsObject:indeString]) {
        [self.defMArray removeObject:indeString];
    }
    if (![self.showInfoListAarry containsObject:indeString] && [indeString intValue] < 1000000) {
        [self.showInfoListAarry addObject:indeString];
    }
    
    if ([indeString intValue] > 1000000) {
        [self.customInfosDic removeObjectForKey:indeString];
        WYLog(@"=== dev temp === customInfosDic: %@", self.customInfosDic);
        if (self.customInfosDic.count < 5 && ![self.showInfoListAarry containsObject:@"14"]) {
            [self.showInfoListAarry addObject:@"14"];
        }
    }
    
    switch ([indeString intValue]) {
        case 0://"昵称"
            self.model.nickname=@"";
            break;
        case 1:
            self.model.gender=@"";
            break;
        case 2:
            self.model.birthday=@"";
            break;
        case 3:
            self.model.avatar=@"";
            break;
        case 4:
            self.model.email=@"";
            break;
        case 5:
            self.model.phoneCode=@"";
            self.model.phone=@"";
            break;
        case 6:
            self.model.nation=@"";
            break;
        case 7:
            self.model.introduction=@"";
            break;
        case 8:
            self.model.homePage=@"";
            break;
        case 9:
            self.model.facebook=@"";
            break;
        case 10:
            self.model.twitter=@"";
            break;
        case 11:
            self.model.weibo=@"";
            break;
        case 12:
            self.model.wechat=@"";
            break;
        case 13:
            self.model.googleAccount=@"";
            break;
        case 14:
            self.model.customInfos = @"";
            break;
        default:
            break;
    }
    
    if ( self.addFooterView.alpha==0) {
        self.addFooterView.alpha=1;
    }
    
    [self.table reloadData];
    
}

-(void)delegateViewWithDic:(NSDictionary *)dic{
    if ( self.addFooterView.alpha==0) {
        self.addFooterView.alpha=1;
    }
    if (self.whereFrome||self.isEidet) {
        self.deleteIndex=@"-1";
        if (self.noAleart) {
            [self delegateInfo];
        }else{
            [self showDeleteHasSaveChainView];
        }
    }else{
        [self updeDeleIphoneNumber];
    }
    
}
-(void)updeDeleIphoneNumber{
    if ([self.defMArray containsObject:@"5"]) {
        [self.defMArray removeObject:@"5"];
    }
    if (![self.showInfoListAarry containsObject:@"5"]) {
        [self.showInfoListAarry addObject:@"5"];
    }
    self.model.phone=@"";
    self.model.phoneCode=@"";
    [self.table reloadData];
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSInteger tag=textField.tag;
    
    switch (tag) {
        case 100://"昵称"
            [self needChangeFrame:tag];
            //               self.model.nickname=textField.text;
            break;
        case 103:
            [self needChangeFrame:tag];
            //               self.model.avatar=textField.text;
            break;
        case 104:
            [self needChangeFrame:tag];
            //               self.model.email=textField.text;
            break;
        case 108:
            
            [self needChangeFrame:tag];
            break;
        case 109:
            [self needChangeFrame:tag];
            //               self.model.facebook=textField.text;
            break;
        case 110:
            [self needChangeFrame:tag];
            //            self.model.twitter=textField.text;
            break;
        case 111:
            [self needChangeFrame:tag];
            //               self.model.weibo=textField.text;
            break;
        case 112:
            [self needChangeFrame:tag];
            //               self.model.wechat=textField.text;
            break;
        case 113:
            [self needChangeFrame:tag];
            //               self.model.googleAccount=textField.text;
            break;
        case 114:
            [self needChangeFrame:tag];
            break;
        case 10001:
            [self needChangeFrame:105];
            //               self.model.phone=textField.text;
            break;
        case 10002:
            [self needChangeFrame:105];
            //               self.model.phoneCode=textField.text;
            break;
        default:
            break;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger tag=textField.tag;
    switch (tag) {
        case 100://"昵称"
            self.model.nickname=textField.text;
            break;
        case 103:
            self.model.avatar=textField.text;
            break;
        case 104:
            self.model.email=textField.text;
            break;
        case 108:
            self.model.homePage=textField.text;
            break;
        case 109:
            self.model.facebook=textField.text;
            break;
        case 110:
            self.model.twitter=textField.text;
            break;
        case 111:
            self.model.weibo=textField.text;
            break;
        case 112:
            self.model.wechat=textField.text;
            break;
        case 113:
            self.model.googleAccount=textField.text;
            break;
        case 114:
            self.model.customInfos=textField.text;
            break;
        case 10001:
            self.model.phone=textField.text;
            break;
        case 10002:
            self.model.phoneCode=textField.text;
            break;
        default:
            break;
    }
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger tag=textField.tag;
    switch (tag) {
        case 100:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:16];
            break;
        case 103:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:100];
            break;
        case 104:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:100];
            break;
        case 108:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:100];
            break;
        case 109:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 110:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 111:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 112:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 113:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 114:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:50];
            break;
        case 10001:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:15];
            break;
        case 10002:
            return  [[FLTools share]textField:textField replacementString:string withStringLenth:6];
            break;
        default:
            return YES;
            break;
    }
    return YES;
}

- (NSMutableArray*)bubblingSort:(NSMutableArray *)sourceArr{
    if (sourceArr.count < 2) {
        return sourceArr;
    }
    
    for (int i = 0; i < sourceArr.count - 1; i++) {
        for (int j = 0; j < sourceArr.count - i - 1; j++) {
            if ([self compareCustom:[sourceArr[j] intValue] greaterThan:[sourceArr[j + 1] intValue]]) {
                [self swap:sourceArr numI:j numJ:j + 1];
            }
        }
    }
    return sourceArr;
}

- (BOOL)compareCustom:(NSInteger)num1 greaterThan:(NSInteger)num2 {
    num1 = (num1 > 1000000) ? num1 % 1000000 + 1000000 : num1;
    num2 = (num2 > 1000000) ? num2 % 1000000 + 1000000 : num2;
    return num1 > num2;
}

- (void)swap:(NSMutableArray *)sourceArr numI:(int)i numJ:(int)j{
    NSNumber *temp;
    temp = sourceArr[i];
    sourceArr[i] = sourceArr[j];
    sourceArr[j] = temp;
}

-(void)showSendSuccessViewWithType:(NSInteger)type{
    self.sendSuccessPopuV =[[HMWSendSuccessPopuView alloc]init];
    switch (type) {
        case 0:
        {
            self.sendSuccessPopuV.type=sendDealType;
            break;
            
        }
        case 1:{
            self.sendSuccessPopuV.type=saveSuccessType;
            break;
        }
            
        default:
            break;
    }
    
    UIView *manView=[self mainWindow];
    [manView addSubview:self.sendSuccessPopuV];
    [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(manView);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendSuccessPopuV removeFromSuperview];
        self.sendSuccessPopuV=nil;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[HWMConfidentialInformationViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)makeSureWithPWD:(NSString*)pwd{
    WYLog(@"=== dev temp === Skip Button: makeSureWithPWD entered!!");
    
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,pwd] callbackId:self.currentWallet.masterWalletID className:@"Wallet" methodName:@"ExportxPrivateKey"];
    NSString *  privatekeyString=[[ELWalletManager share]ExportxPrivateKey:mommand];
    if (privatekeyString.length==0) {
        return;
    }
    NSString *didString=[[HWMDIDManager shareDIDManager]hasDIDWithPWD:pwd withDIDString:@"" WithPrivatekeyString:@"" WithmastWalletID:self.currentWallet.masterWalletID needCreatDIDString:NO];
    if (didString.length==0) {
        return;
    }
    self.currentWallet.didString=didString;
    if (self.isEidet||self.whereFrome) {
        self.model.editTime=[[FLTools share]getNowTimeTimestampS];
        
        WYLog(@"=== dev temp === makeSureWithPWD: model did %@ === birth %@ === customInfos %@", self.model.did, self.model.birthday, self.model.customInfos);
        
        BOOL isSucess=[[HWMDIDManager shareDIDManager ]saveDIDCredentialWithDIDModel: self.model];
        if (isSucess) {
            
//            HWMDIDInfoModel *readModel=[[HWMDIDManager shareDIDManager]readDIDCredential];
//            WYLog(@"=== dev temp === makeSureWithPWD: read model did %@ === birth %@ === customInfos %@", readModel.did, readModel.birthday, readModel.customInfos);
            
            [self hiddenPWDView];
            [self showSendSuccessViewWithType:1];
        } else {
            [[FLTools share]showErrorInfo:@"保存失败"];
        }
    } else {
        if (self.blance<0.0001) {
            [[FLTools share]showErrorInfo:@"余额不足"];
            return;
        }
        
        BOOL isSucess=[[HWMDIDManager shareDIDManager ]updateInfoWithInfo: self.model];
        if (isSucess) {
            if ([self needSave]) {
                self.model.editTime=[[FLTools share]getNowTimeTimestampS];
                [[HWMDIDManager shareDIDManager ]saveDIDCredentialWithDIDModel: self.model];
            }
            [self closeTransactionDetailsView];
            [self hiddenPWDView];
            [self showSendSuccessViewWithType:0];
            FMDBWalletModel *model=[[FMDBWalletModel alloc]init];
            model.walletID=self.currentWallet.masterWalletID;
            model.walletName=self.currentWallet.walletName;
            model.walletAddress=self.currentWallet.walletAddress;
            model.didString=self.currentWallet.didString;
            [[HMWFMDBManager sharedManagerType:walletType]updateRecordWallet:model];
            __weak __typeof__ (self) weakSelf = self;
            if (self.successBlock) {
                weakSelf.successBlock(self.currentWallet.didString);
                [weakSelf.navigationController popViewControllerAnimated:NO];
            }
        } else {
            //            [[FLTools share]showErrorInfo:@"发布失败"];
        }
    }
}

-(HMWpwdPopupView *)pwdPopupV{
    if (!_pwdPopupV) {
        _pwdPopupV=[[HMWpwdPopupView alloc]init];
        _pwdPopupV.delegate=self;
    }
    return _pwdPopupV;
}
-(void)showSendSuccessPopuV{
    UIView *manView=[self mainWindow];
    [manView addSubview:self.sendSuccessPopuV];
    [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(manView);
    }];
    
}
-(void)hiddenSendSuccessPopuV{
    [self.sendSuccessPopuV removeFromSuperview];
    self.sendSuccessPopuV=nil;
    
    
}
-(void)hiddenPWDView{
    [self.pwdPopupV removeFromSuperview];
    self.pwdPopupV=nil;
    
    
}
-(void)cancelThePWDPageView{
    [self hiddenPWDView];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}
-(void)setCurrentWallet:(FLWallet *)currentWallet{
    _currentWallet=currentWallet;
}
-(HMWToDeleteTheWalletPopView *)deleteHasSaveChainView{
    if (!_deleteHasSaveChainView) {
        _deleteHasSaveChainView=[[HMWToDeleteTheWalletPopView alloc]init];
        _deleteHasSaveChainView.delegate=self;
        _deleteHasSaveChainView.deleteType=deleteHasSaveInfoType;
    }
    return _deleteHasSaveChainView;
}
-(void)sureToDeleteViewWithPWD:(NSString*)pwd{
    if ([self.deleteIndex isEqualToString:@"-1"]) {
        [self updeDeleIphoneNumber];
    }else{
        [self delegateInfo];
    }
    [self toCancelOrCloseDelegate];
}
-(void)toCancelOrCloseDelegate{
    self.deleteHasSaveChainView.alpha=0.f;
}
-(void)showDeleteHasSaveChainView{
    if (self.deleteHasSaveChainView.alpha==0.f) {
        self.deleteHasSaveChainView.alpha=1.f;
    }else{
        UIView *mainView= [self mainWindow];
        [mainView addSubview:self.deleteHasSaveChainView];
        [self.deleteHasSaveChainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(mainView);
        }];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.deleteHasSaveChainView) {
        [self.deleteHasSaveChainView removeFromSuperview];
        self.deleteHasSaveChainView=nil;
    }
}
-(void)getBalance{
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.currentWallet.masterWalletID,@"IDChain",@2] callbackId:self.currentWallet.walletID className:@"Wallet" methodName:@"getBalance"];
    PluginResult * result =[[ELWalletManager share]getBalance:mommand];
    NSString *status=[NSString stringWithFormat:@"%@",result.status];
    if ([status isEqualToString:@"1"]){
        NSString *blanceString=[[FLTools share] elaScaleConversionWith:[NSString stringWithFormat:@"%@",result.message[@"success"]]];
        
        WYLog(@"=== dev temp === currentBalance: %@", blanceString);
        
        self.blance=[blanceString doubleValue];
        
        WYLog(@"=== dev temp === self balance: %f", self.blance);
    }
}
-(HMWaddFooterView *)addFooterView{
    if (!_addFooterView) {
        _addFooterView=[[HMWaddFooterView alloc]init];
        _addFooterView.delegate=self;
    }
    return _addFooterView;;
}
-(void)addTheAssetEvent{
    [self.view endEditing:YES];
    [self nextAndSkipEvent:nil];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.table.contentSize = CGSizeMake(0,self.defMArray.count*55+300);
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
-(void)needChangeFrame:(NSInteger)tag{
    NSUInteger indexDe=[self.defMArray indexOfObject:[NSString stringWithFormat:@"%ld",tag-100]];
    [self.table setContentOffset:CGPointMake(0, indexDe*55) animated:YES];
    
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
    if (self.isChain) {
        WYLog(@"=== dev temp === isChain self balance: %f", self.blance);
        
        if (self.blance<0.0001) {
            [[FLTools share]showErrorInfo:@"余额不足"];
            return;
        }
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
            [self closeTransactionDetailsView];
            [self showSendSuccessView];
        }
    } else {
        [self makeSureWithPWD:pwd];
    }
}

- (void)showSendSuccessView{
    self.sendSuccessPopuV =[[HMWSendSuccessPopuView alloc]init];
    UIView *manView=[self mainWindow];
    [manView addSubview:self.sendSuccessPopuV];
    [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(manView);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendSuccessPopuV removeFromSuperview];
        self.sendSuccessPopuV=nil;
        __weak __typeof__ (self) weakSelf = self;
        WYLog(@"== dev temp === successBlock: %@", self.successBlock);
        if (self.successBlock) {
            weakSelf.successBlock(self.currentWallet.didString);
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

-(BOOL)needSave{
    if(self.model.nickname.length>0||self.model.gender.length>0||self.model.avatar.length>0||self.model.email.length>0||self.model.phone.length>0||self.model.phoneCode.length>0||self.model.nation.length>0||self.model.introduction.length>0||self.model.homePage.length>0||self.model.wechat.length>0||self.model.twitter.length>0||self.model.weibo.length>0||self.model.facebook.length>0||self.model.googleAccount.length>0||self.model.birthday.length>0) {
        return YES;
    }
    return NO;
}

@end
