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


#import "ELACRCommitteeListViewController.h"
#import "ELAUtils.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "ELACRCommitteeViewController.h"
#import "ELACommitteeManageViewController.h"
#import "ELACommitteeInfoModel.h"
#import "ELANetwork.h"
#import "ELANetworkManager.h"
#import "HWMSecretaryGeneralAndMembersDetailsModel.h"
#import "HWMSecretaryGeneralAndMembersInfo.h"
#import "ELAVotingProcessUtil.h"
#import "ELWalletManager.h"
#import "ELAInformationDetail.h"
#import "ELASecretaryDetailViewController.h"
#import "MJExtension.h"
#import "FLManageSelectPointNodeInformationVC.h"
#import "HMWFMDBManager.h"
#import "HWMDIDManager.h"
#import "HWMCRListModel.h"
#import "HWMDIDInfoModel.h"
#import "ELANetwork.h"
#import "WYLocalizedOrdinalNumber.h"

@interface ELACRCommitteeListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTableView;

@property (nonatomic, strong) ELACommitteeInfoModel *infoModel;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableDictionary *committeeDic;

@property (nonatomic, strong) NSMutableArray *committeeArray;

@property(strong,nonatomic)HWMDIDInfoModel *DIDmodel;
@property(strong,nonatomic)HWMCRListModel*CRModel;

@end


@implementation ELACRCommitteeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _committeeDic = [[NSMutableDictionary alloc] init];
    _committeeArray = [[NSMutableArray alloc] init];
    
       
    [self creatView];
    [self getNetworkData];
}
- (void)getNetworkData
{
    [self showLoadingView];
    ELAWeakSelf;
    [ELANetwork getCommitteeInfo:^(id  _Nonnull data, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(error)
            {
                if(error.code == -999)
                {
                    [weakSelf hideLoadingView];
                    [weakSelf.contentTableView.mj_header endRefreshing];
                    //已取消
                }
                else
                {
                    [weakSelf hideLoadingView];
                    [weakSelf showErrorInfo:error.localizedDescription];
                    [weakSelf.contentTableView.mj_header endRefreshing];
                }
            }
            else
            {
                ELACommitteeInfoModel *model = data;
                weakSelf.infoModel = model;
                [weakSelf getCouncilListInfo];
//                [weakSelf.contentTableView reloadData];
//                [weakSelf.contentTableView.mj_header endRefreshing];
            }
        });
        
    }];
}

- (void)getCouncilListInfo
{
    FLWallet *wallet = [ELWalletManager share].currentWallet;

    ELAWeakSelf;
    dispatch_group_t group = dispatch_group_create();
    for (ELACommitteeInfoModel *model in _infoModel.data)
    {
        if([model.status isEqualToString:@"VOTING"])
        {
            NSInteger _index = model.index;
            dispatch_group_enter(group);
            BOOL result = [self getRegisteredCRInfo];
            if(result)
            {
                NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", (long)_index];
                ELAInformationDetail *model = [[ELAInformationDetail alloc] init];
                model.type = @"Registered_key";
                if(model)
                    [weakSelf.committeeDic setValue:model forKey:key];
            }
            else
            {
                NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", (long)_index];
                ELAInformationDetail *model = [[ELAInformationDetail alloc] init];
                model.type = @"URegistered_key";
                if(model)
                    [weakSelf.committeeDic setValue:model forKey:key];
            }
            dispatch_group_leave(group);
//            [ELANetwork listcrcandidates:@"all" block:^(id  _Nonnull data, NSError * _Nonnull error){
//                NSInteger _index = model.index;
//                if(error)
//                {
//                    if(error.code == -999)
//                    {
//                        //已取消
//                    }
//                    else
//                    {
//                    }
//                }
//                else
//                {
//
//                    NSDictionary *result = data[@"data"][@"result"];
//                    if(result)
//                    {
//                        NSArray *array = result[@"crcandidatesinfo"];
////                    NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", (long)_index];
////                    ELAInformationDetail *model = data;
//                    [self CRC:array];
//                    }
//                }
//                dispatch_group_leave(group);
//
//
//            }];
        }
        else
        {
            dispatch_group_enter(group);
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [ELANetwork getInformation:wallet.didString ID:model.index block:^(id  _Nonnull data, NSError * _Nonnull error) {
                    
                    NSInteger _index = model.index;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
//                        [weakSelf hideLoadingView];
                        if(error)
                        {
                            if(error.code == -999)
                            {
                                //已取消
                            }
                            else
                            {
                                [weakSelf showErrorInfo:error.localizedDescription];
                            }
                        }
                        else
                        {
                            NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", (long)_index];
                            ELAInformationDetail *model = data;
                            if(model)
                                [weakSelf.committeeDic setValue:model forKey:key];
                        }
                    });
                    dispatch_group_leave(group);
                }];
            });
        }
    }
          
        
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf hideLoadingView];
            [weakSelf.contentTableView reloadData];
            [weakSelf.contentTableView.mj_header endRefreshing];
            ELAInformationDetail *model = [ELAVotingProcessUtil shareVotingProcess].detailModel;
            if (model)
            {
                if ([model.type isEqualToString:@"SecretaryGeneral"])
                {
                    UIButton *rightBarButton = [[UIButton alloc]init];
                    [rightBarButton setImage:ImageNamed(@"cr_sg_icon") forState:(UIControlStateNormal)];
                    [rightBarButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBarButton];
                    self.navigationItem.rightBarButtonItem = rightItem;
                }
            }
        });
    });
    
}

- (BOOL)getRegisteredCRInfo
{
    ELWalletManager *manager   =  [ELWalletManager share];
    IMainchainSubWallet *mainchainSubWallet = [manager getWalletELASubWallet:manager.currentWallet.masterWalletID];
    nlohmann::json info = mainchainSubWallet->GetRegisteredCRInfo();
    NSString *dataStr = [NSString stringWithUTF8String:info.dump().c_str()];
    if(dataStr && ![dataStr isEqualToString:@""])
    {
        NSDictionary *param = [NSJSONSerialization JSONObjectWithData:[dataStr  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *status = param[@"Status"];
        if(status && [status isEqualToString:@"Registered"])
        {
            return YES;
        }
    }
    return NO;
//    FLWallet *wallet = [ELWalletManager share].currentWallet;
//    NSString *key = wallet.didString;
//    if(crcArray && crcArray.count > 0)
//    {
//        for (NSDictionary *dic in crcArray)//网路数组获取每个字典
//        {
//            NSString *cid = dic[@"cid"];//取字典中cid
//            NSString *state = dic[@"code"];//取字典中code
//            if([key isEqualToString:cid])//key 与 cid 相同
//            {
//                if([state isEqualToString:@"Active"])//有效
//                {
//                    return YES;;
//                }
//                else
//                {
//                    return NO;
//                }
//                break;
//            }
//        }
//
//    }
//    return NO;
}

- (void)getCrc:(NSArray *)crcArray
{
//    FLWallet *wallet = [ELWalletManager share].currentWallet;
//    NSString *key = wallet.didString;
//    if(crcArray && crcArray.count > 0)
//    {
//        for (NSDictionary *dic in crcArray)//网路数组获取每个字典
//        {
//            NSString *cid = dic[@"cid"];//取字典中cid
//            NSString *state = dic[@"code"];//取字典中code
//            if([key isEqualToString:cid])//key 与 cid 相同
//            {
//                if([state isEqualToString:@"Active"])//有效
//                {
//                    return YES;;
//                }
//                else
//                {
//                    return NO;
//                }
//                break;
//            }
//        }
//
//    }
    
}
#pragma mark - Action

//- (void)goBack
//{
//    AFHTTPSessionManager *manager = [ELANetworkManager getManager];
//    if (manager.tasks.count > 0)
//    {
//        [manager.operationQueue cancelAllOperations];
////        [_task cancel];
//     //   [manager.tasks makeObjectsPerformSelector:@selector(cancel)];
//    }
//        
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)rightButtonAction:(id)sender
{
    FLWallet *wallet = [ELWalletManager share].currentWallet;
    
    ELASecretariatModel *model = [[ELASecretariatModel alloc] init];
    model.did = wallet.didString;
    ELASecretaryDetailViewController *vc = [[ELASecretaryDetailViewController alloc] init];
    vc.title = ELALocalizedString(@"秘书长详情");
    vc.paramModel = model;
    vc.index = -1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)manageButtonAction:(id)sender
{
//    [self votingElectionButtonAction:sender];
    UIButton *button  = sender;
    NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", button.tag];
    ELAInformationDetail *detailModel = [_committeeDic valueForKey:key];

    ELACommitteeManageViewController *vc = [[ELACommitteeManageViewController alloc] init];
    vc.infoModel = detailModel;
    vc.type = 1;
    vc.title = ELALocalizedString(@"选举管理");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)electionButtonAction:(id)sender
{
    UIButton *button  = sender;
    NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", button.tag];
    ELAInformationDetail *detailModel = [_committeeDic valueForKey:key];
    
    ELACommitteeManageViewController *vc = [[ELACommitteeManageViewController alloc] init];
    vc.infoModel = detailModel;
    vc.type = 2;
    vc.title = ELALocalizedString(@"委员管理");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)votingElectionButtonAction:(id)sender //选举管理 voting
{
    [self getNetCoinPointArray];
}
-(void)getNetCoinPointArray
{
    [self showLoading];
    ELAWeakSelf;
    FLWallet *wallet = [ELWalletManager share].currentWallet;
    NSString *httpIP=[[FLTools share]http_IpFast];
    [HttpUrl NetPOSTHost:httpIP url:@"/api/dposnoderpc/check/listcrcandidates" header:@{} body:@{@"state":@"all"} showHUD:NO WithSuccessBlock:^(id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hiddLoading];
            NSDictionary *param = data[@"data"];
            NSArray *dataArray =[NSArray modelArrayWithClass:HWMCRListModel.class json:param[@"result"][@"crcandidatesinfo"]];
            for (int i= 0; i<dataArray.count; i++)
            {
                
                HWMCRListModel *model = dataArray[i];
                
                NSString *did1 = [model.did stringByReplacingOccurrencesOfString:@"did:elastos:" withString:@""];
                NSString *did2 = [wallet.didString stringByReplacingOccurrencesOfString:@"did:elastos:" withString:@""];
                if([did1 isEqualToString:did2])
                {
                    if ([model.state isEqualToString:@"Active"])
                    {
                        weakSelf.CRModel = model;
                        if ([[FLTools share]isBlankString:model.url])
                        {
                            weakSelf.CRModel.url = @" ";
                        }
                        //                        [weakSelf getCRInfo:weakSelf.CRModel];
                        FLWallet *wallet = [ELWalletManager share].currentWallet;
                        FLManageSelectPointNodeInformationVC *vc= [[FLManageSelectPointNodeInformationVC alloc]init];
                        vc.currentWallet = wallet;
                        vc.CRTypeString = @"CR";
                        
                        vc.CRModel = weakSelf.CRModel;
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    }
                    break;
                }
                
            }
        });

    } WithFailBlock:^(id data) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf hiddLoading];
            [weakSelf showErrorInfo:ERRORDESC];
        });
        
    }];
}

-(void)getCRInfo:(HWMCRListModel *)model
{
    ELAWeakSelf
    NSString *httpIP=[[FLTools share]http_IpFast];
    [HttpUrl NetPOSTHost:httpIP url:@"/api/dposnoderpc/check/jwtget" header:@{} body:@{@"did":[NSString stringWithFormat:@"did:elastos:%@",model.cid]} showHUD:NO WithSuccessBlock:^(id data) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hiddLoading];
            NSString *jwtString=data[@"data"][@"jwt"];
            if(jwtString && ![jwtString isEqualToString:@""])
            {
                NSDictionary *playInfoDic=[[HWMDIDManager shareDIDManager]CRInfoDecodeWithJwtStringInfo:jwtString];
                weakSelf.DIDmodel=[HWMDIDInfoModel modelWithJSON:playInfoDic[@"credentialSubject"]];
                
                weakSelf.CRModel.iconImageUrl=weakSelf.DIDmodel.avatar;
                weakSelf.CRModel.infoEN=weakSelf.DIDmodel.introduction;
                weakSelf.CRModel.infoZH=weakSelf.DIDmodel.introduction;
                
                FLWallet *wallet = [ELWalletManager share].currentWallet;
                FLManageSelectPointNodeInformationVC *vc= [[FLManageSelectPointNodeInformationVC alloc]init];
                vc.currentWallet = wallet;
                vc.CRTypeString = @"CR";
                
                weakSelf.CRModel.didIndoModel = weakSelf.DIDmodel;
                vc.CRModel = weakSelf.CRModel;
                [self.navigationController pushViewController:vc animated:YES];
            }
        });
        
    } WithFailBlock:^(id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf hiddLoading];
            [weakSelf showErrorInfo:ERRORDESC];
        });
    }];
}



#pragma mark -

- (void)loadNewData
{
    [_contentTableView.mj_header beginRefreshing];
    [self getNetworkData];
}

- (void)loadMoreData
{
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_infoModel.data)
    {
        return _infoModel.data.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *identifier = @"TableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    NSArray *subViews = [cell.contentView subviews];
    for(UIView *view in subViews)
    {
        [view removeFromSuperview];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ELACommitteeInfoModel *model = nil;
    NSString *titleStr = @"";
    NSString *dateStr = @"";
    NSString *buttonStr = @"";
    int type = 0;
    if(_infoModel.data)
    {
        
        model = [_infoModel.data objectAtIndex:indexPath.section];;

        
        NSString *key = [NSString stringWithFormat:@"%@%ld", @"info", model.index];
        ELAInformationDetail *detailModel = [_committeeDic valueForKey:key];
        NSString *status = @"";
        
        if(model.status && [model.status isEqualToString:@"HISTORY"])
        {
            if([detailModel.type isEqualToString:@"UnelectedCouncilMember"] && ![detailModel.depositAmount isEqualToString:@""]
               && ![detailModel.depositAmount isEqualToString:@"0"])
            {
                buttonStr = ELALocalizedString(@"选举管理");
                type = 1;
            }

                    
        }
        else if(model.status && [model.status isEqualToString:@"CURRENT"])
        {
            status = ELALocalizedString(@"本届");
            if([detailModel.type isEqualToString:@"CouncilMember"])
            {
                buttonStr = ELALocalizedString(@"委员管理");
                type = 2;
            }
            else if([detailModel.type isEqualToString:@"UnelectedCouncilMember"] && ![detailModel.depositAmount isEqualToString:@""]
                    && ![detailModel.depositAmount isEqualToString:@"0"])
            {
                buttonStr = ELALocalizedString(@"选举管理");
                type = 1;
            }
        }
        else if(model.status && [model.status isEqualToString:@"VOTING"])
        {
            status = ELALocalizedString(@"选举中");
            if([detailModel.type isEqualToString:@"Registered_key"])
            {
                buttonStr = ELALocalizedString(@"选举管理");
                type = 3;
            }
            else if([detailModel.type isEqualToString:@"URegistered_key"])
            {
//                buttonStr = ELALocalizedString(@"选举管理");
                type = 0;
            }
        }
        
        NSString *termNo = [WYLocalizedOrdinalNumber stringFromNumber:@(model.index)];
//        NSLog(@" === localized Term number: %@ === ", termNo);
        if ([termNo hasPrefix:@"第"]) {
            termNo = [termNo substringFromIndex:1];
        }

        titleStr = [NSString stringWithFormat:@"%@ %@ %@ (%@)", ELALocalizedString(@"第"), termNo, ELALocalizedString(@"届"), status];
        dateStr = [NSString stringWithFormat:@"%@-%@", [ELAUtils getTime:model.startDate],
                   [ELAUtils getTime:model.endDate]];
    }
    UIView *infoView = [[UIView alloc] init];
    infoView.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:infoView];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.2;
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 10;
    [infoView addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = titleStr;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = PingFangRegular(14);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    [infoView addSubview:titleLabel];
    
    UILabel *subLabel = [[UILabel alloc] init];
    subLabel.text = dateStr;
    subLabel.textColor = [UIColor whiteColor];//ELARGB(131, 144, 154);
    subLabel.font = PingFangRegular(12);
    subLabel.textAlignment = NSTextAlignmentLeft;
    subLabel.alpha = 0.5;
    [infoView addSubview:subLabel];

    UIView *buttonBg = [[UIView alloc] init];
    buttonBg.layer.masksToBounds = YES;
    buttonBg.layer.cornerRadius = 5;
    buttonBg.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonBg.layer.borderWidth = 1;
    buttonBg.backgroundColor = ELARGB(83, 136, 136);
    [infoView addSubview:buttonBg];
    
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = PingFangRegular(14);
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:buttonStr forState:(UIControlStateNormal)];
    button.tag = model.index;
    if(type == 1)
    {
        [button addTarget:self action:@selector(manageButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if(type == 2)
    {
        [button addTarget:self action:@selector(electionButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if(type == 3)
    {
        [button addTarget:self action:@selector(votingElectionButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else
    {
        button.hidden = YES;
        buttonBg.hidden = YES;
    }
    [infoView addSubview:button];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = ImageNamed(@"asset_list_arrow");
    [infoView addSubview:imageView];

    if(indexPath.section < 3)
    {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgView).offset(-15);
            make.centerY.equalTo(titleLabel);
        }];
        
        [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView);
            make.top.equalTo(cell.contentView);
            make.height.equalTo(cell.contentView);
            make.bottom.equalTo(cell.contentView).offset(0);
        }];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(infoView).offset(15);
            make.right.equalTo(infoView).offset(-15);
            make.top.equalTo(infoView);
            make.height.equalTo(infoView);
            make.bottom.equalTo(infoView).offset(0);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(15);
            make.right.equalTo(bgView).offset(-15);
            make.top.equalTo(bgView).offset(15);
        }];
        
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel);
            make.top.equalTo(titleLabel.mas_bottom).offset(25);
            make.bottom.equalTo(infoView).offset(-25);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(imageView);
            make.centerY.equalTo(subLabel);
//            make.width.equalTo(@(90));
            make.height.equalTo(@(30));
        }];
        
        [buttonBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(button.mas_right).offset(5);
            make.centerY.equalTo(subLabel);
            make.left.equalTo(button.mas_left).offset(-5);
            make.height.equalTo(button);
        }];
    }
    else
    {
        bgView.alpha = 0;
       // titleLabel.text = titleStr;//ELALocalizedString(@"第10届");
        
        [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView);
            make.top.equalTo(cell.contentView);
            make.height.equalTo(cell.contentView);
            make.bottom.equalTo(cell.contentView).offset(0);
        }];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(infoView).offset(0);
            make.right.equalTo(infoView).offset(0);
            make.top.equalTo(infoView);
            make.height.equalTo(infoView);
            make.bottom.equalTo(infoView).offset(0);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgView).offset(-15);
            make.centerY.equalTo(bgView);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(15);
            make.right.equalTo(bgView).offset(-15);
            make.top.equalTo(bgView).offset(15);
        }];
        
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel);
            make.top.equalTo(titleLabel.mas_bottom).offset(10);
            make.bottom.equalTo(infoView).offset(-15);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(imageView);
            make.centerY.equalTo(subLabel);
         //   make.width.equalTo(@(90));
            make.height.equalTo(@(30));
        }];
        button.hidden = YES;
        buttonBg.hidden = YES;
        
        UIView *_line = [[UIView alloc] init];
        _line.backgroundColor = ELARGB(149, 159, 171);//[UIColor whiteColor];
        [infoView addSubview:_line];
        
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel);
            make.top.equalTo(infoView.mas_bottom).offset(-0.5);
            make.right.equalTo(imageView.mas_right);
            make.height.equalTo(@(0.5));
        }];
        
        
    }

    return cell;
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ELACommitteeInfoModel *model = nil;
    if(_infoModel.data)
    {
        model = [_infoModel.data objectAtIndex:indexPath.section];
        ELACRCommitteeViewController *vc = [[ELACRCommitteeViewController alloc] init];
        
        NSString *termNo = [WYLocalizedOrdinalNumber stringFromNumber:@(model.index)];
//        NSLog(@" === localized Term number: %@ === ", termNo);
        if ([termNo hasPrefix:@"第"]) {
            termNo = [termNo substringFromIndex:1];
        }
        
        NSString *str = [NSString stringWithFormat:@"%@ %@ %@ %@", ELALocalizedString(@"第"), termNo, ELALocalizedString(@"届"),  ELALocalizedString(@"CR委员会")];
        vc.title = str;//ELALocalizedString(@"CR委员会");
        vc.index = model.index;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


#pragma mark - View

- (void)creatView
{
    _contentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    [_contentTableView setBackgroundColor:[UIColor clearColor]];
    _contentTableView.rowHeight = UITableViewAutomaticDimension;
    _contentTableView.estimatedRowHeight = 44;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(NavigitionBarHeight);
        make.bottom.mas_equalTo(0);
    }];
//    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
//    _contentTableView.mj_header = header;
//    [_contentTableView.mj_header beginRefreshing];
    
    
//    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    _contentTableView.mj_footer = footer;
    
//   _contentTableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//
//   }];
//   _contentTableView.mj_footer= [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//
//
//   }];
    
}

@end
