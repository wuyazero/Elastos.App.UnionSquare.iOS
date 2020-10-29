//
//  HWMHWMDIDShowInfoViewController.m
//  elastos wallet
//
//  Created by  on 2020/2/14.
//

#import "HWMHWMDIDShowInfoViewController.h"
#import "HWMDIDInfoShowTableViewCell.h"
#import "HWMAddPersonalInformationViewController.h"
#import "HWMshowIntroductionInfoViewController.h"
#import "WYShowCustomContentViewController.h"

static NSString *cellString =@"HWMDIDInfoShowTableViewCell";

@interface HWMHWMDIDShowInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;

@property(strong,nonatomic)UIButton *skipButton;
@property(strong,nonatomic)NSArray *allInfoListArray;
@property(strong,nonatomic)NSMutableArray *hasModelAarray;
@property(assign,nonatomic)NSInteger headImageIndex;

@property (strong, nonatomic) NSMutableDictionary *customInfosDic;

@end

@implementation HWMHWMDIDShowInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title=NSLocalizedString(@"个人信息",nil);
    if (self.isEi==YES) {
        self.skipButton.alpha=0;
        self.title=NSLocalizedString(@"个人资料",nil);
    }
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:self.skipButton];
    
    [self makeUI];
    
}
-(NSMutableArray *)hasModelAarray{
    if (!_hasModelAarray) {
        _hasModelAarray=[[NSMutableArray alloc]init];
    }
    return _hasModelAarray;
}
-(void)makeUI{
    [self.table registerNib:[UINib nibWithNibName:cellString bundle:nil] forCellReuseIdentifier:cellString];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate =self;
    self.table.dataSource =self;
    self.table.backgroundColor=[UIColor clearColor];
}
-(UIButton *)skipButton{
    if (!_skipButton) {
        _skipButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_skipButton setImage:[UIImage imageNamed:@"asset_edit"] forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipButton.titleLabel.font=[UIFont systemFontOfSize:14];
        [_skipButton addTarget:self action:@selector(skipVCEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}
-(void)skipVCEvent{
    HWMAddPersonalInformationViewController *HWMAddPersonalInformationVC=[[HWMAddPersonalInformationViewController alloc]init];
    HWMAddPersonalInformationVC.isEidet=YES;
    HWMAddPersonalInformationVC.model=self.model;
    HWMAddPersonalInformationVC.currentWallet=self.currentWallet;
    [self.navigationController pushViewController:HWMAddPersonalInformationVC animated:YES];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infDic=self.hasModelAarray[indexPath.row];
    
    NSString *titleString=infDic[@"text"];
    NSString *typeString=infDic[@"type"];
    NSString *indexString=infDic[@"index"];
    NSString *conString;
    HWMDIDInfoShowTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellString];
    switch ([indexString integerValue]) {
        case 0:
            if (self.isEi) {
                conString=self.model.didName;
            }else{
                conString=self.model.nickname;
            }
            
            break;
        case 1:
            conString=[[FLTools share]genderStringWithType:self.model.gender];
            break;
        case 2:
            conString=[[FLTools share]TimeFormatConversionBirthday:self.model.birthday];
            break;
        case 3:{
            cell.headIocnImageView.alpha=1.f;
            if (self.model.avatar.length>4) {
               
                NSString *typeString=[self.model.avatar substringFromIndex:self.model.avatar.length-4];
                if ([typeString isEqualToString:@".svg"]) {
                    cell.headIocnImageView.contentMode=UIViewContentModeScaleAspectFit;
                }else{
                    cell.headIocnImageView.contentMode=UIViewContentModeScaleAspectFill;
                }
                [[FLTools share]loadUrlSVGAndPNG:self.model.avatar WithSuccessBlock:^(id data) {
                    if (data) {
                        cell.headIocnImageView.image=data;
                    }else{
                        cell.headIocnImageView.image=[UIImage imageNamed:@"mine_did_default_avator"];
                    }
                }];
            }else{
                cell.headIocnImageView.image=[UIImage imageNamed:@"mine_did_default_avator"];
            }
            cell.rightLabel.alpha=0.f;
            
        }
            break;
        case 4:
            conString=self.model.email;//
            break;
        case 5:
            conString=[NSString stringWithFormat:@"%@ %@",self.model.phoneCode,self.model.phone];
            break;
        case 6:
            conString=[[FLTools share]contryNameTransLateByCode:[self.model.nation integerValue]];
            break;
        case 7:
            conString=self.model.introduction;//简介
            break;
        case 8:
            conString=self.model.homePage;
            break;
        case 9:
            conString=self.model.facebook;
            break;
        case 10:
            conString=self.model.twitter;
            break;
        case 11:
            conString=self.model.weibo;
            break;
        case 12:
            conString=self.model.wechat;
            break;
        case 13:
            conString=self.model.googleAccount;
            break;
        case 14:
            conString=self.model.customInfos;
            break;
        default:
            break;
    }
    
    if ([typeString isEqualToString:@"666"] && self.customInfosDic[indexString]) {
        NSDictionary *infoDic = self.customInfosDic[indexString];
        NSString *cellType = infoDic[@"type"];
        if (cellType.length > 0) {
            titleString = infoDic[@"title"];
            conString = infoDic[@"content"];
        }
    }
    
    cell.leftLabel.text=titleString;
    cell.rightLabel.text=[conString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.hasModelAarray.count;
}
-(NSArray *)allInfoListArray{
    if (!_allInfoListArray) {
        NSString *nickNameStirng=NSLocalizedString(@"昵称", nil);
        if (self.isEi) {
            nickNameStirng=NSLocalizedString(@"姓名", nil);
        }
        _allInfoListArray = @[
        @{@"text": nickNameStirng,@"index":@"0",@"type":@"1"},@{@"text":NSLocalizedString(@"性别",nil),@"index":@"1",@"type":@"2"},@{@"text":NSLocalizedString(@"出生日期",nil),@"index":@"2",@"type":@"2"},@{@"text":NSLocalizedString(@"头像地址1",nil),@"index":@"3",@"type":@"1"},@{@"text":NSLocalizedString(@"邮箱1",nil),@"index":@"4",@"type":@"1"},@{@"text":NSLocalizedString(@"手机号", nil) ,@"index":@"5",@"type":@"3"},@{@"text":NSLocalizedString(@"国家/地区1", nil),@"index":@"6",@"type":@"2"},@{@"text":NSLocalizedString(@"个人简介qe",nil),@"index":@"7",@"type":@"4"},@{@"text":NSLocalizedString(@"个人主页",nil),@"index":@"8",@"type":@"1"},@{@"text":NSLocalizedString(@"Facebook账号",nil),@"index":@"9",@"type":@"1"},@{@"text":NSLocalizedString(@"Twitter账号",nil),@"index":@"10",@"type":@"1"},@{@"text":NSLocalizedString(@"微博账号",nul),@"index":@"11",@"type":@"1"},@{@"text":NSLocalizedString(@"微信账号",null),@"index":@"12",@"type":@"1"},
        @{@"text":NSLocalizedString(@"谷歌账号",null),@"index":@"13",@"type":@"1"},
        @{@"text":NSLocalizedString(@"自定义信息",null),@"index":@"14",@"type":@"666"}
        ];
    }
    return _allInfoListArray;
    
}

- (NSMutableDictionary *)customInfosDic {
    if (!_customInfosDic) {
        _customInfosDic = [[NSMutableDictionary alloc] init];
    }
    return _customInfosDic;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.headImageIndex==indexPath.row) {
        return 80;
    }
    return 50;
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=self.hasModelAarray[indexPath.row];
    if ([dic[@"text"] isEqualToString:NSLocalizedString(@"个人简介qe",nil)]) {
        HWMshowIntroductionInfoViewController *AddPersonalProfileVC=[[HWMshowIntroductionInfoViewController alloc]init];
        AddPersonalProfileVC.model=self.model;
        [self.navigationController pushViewController:AddPersonalProfileVC animated:YES];
    } else if ([dic[@"type"] isEqualToString:@"666"]) {
        NSString *indexString = dic[@"index"];
        NSDictionary *infoDic = self.customInfosDic[indexString];
        if ([infoDic[@"type"] isEqualToString:@"-2"]) {
            WYShowCustomContentViewController *contentVC = [[WYShowCustomContentViewController alloc] init];
            contentVC.title = infoDic[@"title"];
            contentVC.contentText = infoDic[@"content"];
            [contentVC refreshData];
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
}
-(void)setModel:(HWMDIDInfoModel *)model{
    
    if (self.isEi==YES) {
        if (model.didName.length>0) {
            [self.hasModelAarray addObject:self.allInfoListArray[0]];
        }
    }else{
        if (model.nickname.length>0) {
            [self.hasModelAarray addObject:self.allInfoListArray[0]];
        }
    }
    
    if (model.gender.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[1]];
    }
    if (model.birthday.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[2]];
    }
    if (model.avatar.length>0&&self.isEi==NO) {
        [self.hasModelAarray addObject:self.allInfoListArray[3]];
        self.headImageIndex=self.hasModelAarray.count-1;
    }else{
        self.headImageIndex=-1;
    }
    if (model.email.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[4]];
    }
    if (model.phone.length>0&&self.isEi==NO) {
        [self.hasModelAarray addObject:self.allInfoListArray[5]];
    }
    if (model.nation.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[6]];
    }
    if (model.introduction.length>0&&self.isEi==NO) {
        [self.hasModelAarray addObject:self.allInfoListArray[7]];
    }
    if (model.homePage.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[8]];
    }
    if (model.facebook.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[9]];
    }
    if (model.twitter.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[10]];
    }
    if (model.weibo.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[11]];
    }
    if (model.wechat.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[12]];
    }
    if (model.googleAccount.length>0) {
        [self.hasModelAarray addObject:self.allInfoListArray[13]];
    }
    if (model.customInfos.length>0) {
        NSDictionary *customInfosList = [WYUtils dicFromJSONString:model.customInfos];
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
            [self.hasModelAarray addObject:@{
                @"index": indexStr,
                @"type": @"666",
                @"text": @""
            }];
            self.customInfosDic[indexStr] = customInfo;
        }
    }
    _model=model;
}
@end
