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


#import "HWMCollectionProposalPerformViewController.h"
#import "HWMCommentPerioDetailsHeadView.h"
#import "HWMCommitteeMembersToVoteView.h"
#import "HWMCRProposalConfirmView.h"
#import "HMWSendSuccessPopuView.h"
#import "HWMCRSuggestionNetWorkManger.h"
#import "HWMDetailsProposalModel.h"
#import "HWMDetailsProposalViewModel.h"
#import "HWMAbstractTableViewCell.h"
#import "HWMCommitteeMembersToVoteTableViewCell.h"
#import "HWMSecretaryGeneralTableViewCell.h"

static NSString *cellCommitteeMembersString=@"HWMCommitteeMembersToVoteTableViewCell";
static NSString *cellSecretaryGeneral=@"HWMSecretaryGeneralTableViewCell";
UINib *ProposalPerform;
static NSString *BaseTableViewCell=@"HWMAbstractTableViewCell";
@interface HWMCollectionProposalPerformViewController ()<UITableViewDelegate,UITableViewDataSource,HWMCRProposalConfirmViewDelgate,HWMCommentPerioDetailsHeadViewDelegate,HWMCommitteeMembersToVoteViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *baseTable;
@property(strong,nonatomic)HMWSendSuccessPopuView*sendSuccessPopuV;
@property(strong,nonatomic)HWMCommentPerioDetailsHeadView*headView;
@property(strong,nonatomic)HWMCommitteeMembersToVoteView*foodView;
@property(strong,nonatomic)HWMCRProposalConfirmView*CRProposalConfirmV;
@property(strong,nonatomic)HWMDetailsProposalModel*DetailsModel;
@property(copy,nonatomic)NSArray*cellInfoArray;
@property(assign,nonatomic)BOOL isOpen;
@property(assign,nonatomic)BOOL isSecOpen;
@property(assign,nonatomic)CGFloat secHeight;
@end

@implementation HWMCollectionProposalPerformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title=NSLocalizedString(@"提案执行", nil);//执行中
    
    switch (self.type) {
        case CommentPerioVOTINGType:
            self.title=NSLocalizedString(@"提案评议", nil);
            break;
        case CommentPerioNOTIFICATIONType:
            self.title=NSLocalizedString(@"提案公示", nil);
            break;
        case CommentPerioACTIVEType:
            self.title=NSLocalizedString(@"提案执行", nil);
            break;
        case CommentPerioFINALType:
            self.title=NSLocalizedString(@"提案完成", nil);
            break;
        case CommentPerioREJECTEDType:
        case CommentPerioVETOEDType:
            self.title=NSLocalizedString(@"提案废止", nil);
            break;
        default:
            self.title=NSLocalizedString(@"社区提案", nil);
    }
    
    self.headView.model=self.model;
    [self makeView];
    self.isOpen=NO;
    self.isSecOpen=NO;
//    CGFloat showNw=0;
//    if (self.DetailsModel.trackingResult.count==0) {
//        showNw=100;
//    }
//    self.secHeight=330+showNw;
    [self loadPerioDetailsWithID:self.model.ID];
    if (self.type==CommentPerioACTIVEType) {
    }else if(self.type==CommentPerioFINALType){
    }

}
-(void)loadPerioDetailsWithID:(NSString*)ID{
    self.baseTable.alpha=0.f;
    [self showLoading];
    [[HWMCRSuggestionNetWorkManger shareCRSuggestionNetWorkManger]reloadCRSuggestionDetailsWithID:ID withComplete:^(id  _Nonnull data) {
        [self hiddLoading];
        [[HWMDetailsProposalViewModel alloc]detailsProposalModelDataJosn:data[@"data"] completion:^(HWMDetailsProposalModel * _Nonnull model){
            self.DetailsModel=model;
            self.foodView.DetailsProposalM=self.DetailsModel;
//            [self.baseTable reloadData];
            self.baseTable.alpha=1.f;
            [self.headView needClose];
            [self.foodView closInfo];
        }];
    }];
}
-(void)makeView{
    self.baseTable.delegate=self;
    self.baseTable.dataSource=self;
    self.baseTable.backgroundColor=[UIColor clearColor];
    ProposalPerform =[UINib nibWithNibName:cellCommitteeMembersString bundle:nil];
    [self.baseTable registerNib:[UINib nibWithNibName:BaseTableViewCell bundle:nil] forCellReuseIdentifier:BaseTableViewCell];
    [self.baseTable registerNib:[UINib nibWithNibName:cellSecretaryGeneral bundle:nil] forCellReuseIdentifier: cellSecretaryGeneral];
    [self.baseTable registerNib:ProposalPerform forCellReuseIdentifier:cellCommitteeMembersString];
    self.baseTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, 90+self.model.cellHeight)];
    [headView addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(headView);
    }];
    self.baseTable.tableHeaderView=headView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isOpen) {
        return self.cellInfoArray.count+1;
    }
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.isOpen==NO) {
        if (section==0) {
            return [self setTableViewFootViewWithHeight:self.secHeight];
        }
    }else{
        if (section==3) {
            return [self setTableViewFootViewWithHeight:self.secHeight];
        }
    }
    return [[UIView alloc]initWithFrame:CGRectZero];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isOpen==NO) {
        if (section==0) {
            return self.secHeight;
        }
    }else{
        if (section==3) {
            return self.secHeight;
        }
    }
    return 0.01;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ((self.isOpen==NO&&section==1)||(self.isOpen==YES&&section==4)){
        return self.DetailsModel.trackingResult.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&&self.isOpen) {
        return 0.01;
    }
    if ((self.isOpen==NO&&indexPath.section==1)||(self.isOpen==YES&&indexPath.section==4)){
        HWMVoteResultModel *model=self.DetailsModel.trackingResult[indexPath.row];
        if (model.commentModel.createdBy) {
            UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.frame.size.height;
        }
        return model.reasonCell+70;
    }
    if (indexPath.section==3||self.isOpen==NO) {
        return self.DetailsModel.abstractCell+50;
    }
    if ([self.cellInfoArray[indexPath.section] isEqualToString:NSLocalizedString(@"提案哈希", nil)]) {
           return 90;
       }
    return 70;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((self.isOpen==NO&&indexPath.section==1)||(self.isOpen==YES&&indexPath.section==4)){
        CGFloat isHid=0.f;
        if (indexPath.row!=self.DetailsModel.trackingResult.count-1) {
            isHid=1.f;
        }
        HWMVoteResultModel *model=self.DetailsModel.trackingResult[indexPath.row];
        if (model.commentModel.createdBy) {
            HWMSecretaryGeneralTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellSecretaryGeneral];
            cell.backgroundColor=[UIColor clearColor];
            cell.performModel=model;
            cell.makeLine.alpha=isHid;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            HWMCommitteeMembersToVoteTableViewCell *cell=[ProposalPerform instantiateWithOwner:nil options:nil].firstObject;
            cell.backgroundColor=[UIColor clearColor];
            cell.performModel=model;
            cell.makeLine.alpha=isHid;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        
    }
    HWMAbstractTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:BaseTableViewCell];
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.titleLabel.text=self.cellInfoArray[indexPath.section];
    if (self.isOpen==NO){
        cell.titleLabel.text=self.cellInfoArray.lastObject;
        cell.constLabel.text=self.DetailsModel.abstract;
        return cell;
        
    }
    switch (indexPath.section) {
        case 0:
            cell.constLabel.text=self.DetailsModel.duration;
            cell.alpha=0.f;
            break;
        case 1:
            cell.constLabel.numberOfLines=0.f;
            cell.constLabel.text=self.model.proposalHash;
            break;
        case 2:
            cell.constLabel.text=self.DetailsModel.address;
            cell.constLabel.textColor=RGBA(28, 164, 252, 1);
            cell.constLabel.userInteractionEnabled=YES;
            break;
        case 3:
            cell.constLabel.text=self.DetailsModel.abstract;
            break;
        default:
            break;
    }
    return cell;
}
-(HWMCommentPerioDetailsHeadView *)headView{
    if (!_headView) {
        _headView =[[HWMCommentPerioDetailsHeadView alloc]init];
        _headView.delegate=self;
    }
    return _headView;
}
-(HWMCommitteeMembersToVoteView *)foodView{
    if (!_foodView) {
        _foodView=[[HWMCommitteeMembersToVoteView alloc]init];
        _foodView.delegate=self;
    }
    return _foodView;;
    
}
-(HWMCRProposalConfirmView *)CRProposalConfirmV{
    if (!_CRProposalConfirmV) {
        _CRProposalConfirmV=[[HWMCRProposalConfirmView  alloc]init];
        _CRProposalConfirmV.delegate=self;
    }
    return _CRProposalConfirmV;
    
}
-(void)closeCRProposalConfirmView{
    [self.CRProposalConfirmV removeFromSuperview];
    self.CRProposalConfirmV=nil;
}
-(void)CRProposalConfirmWithPWD:(NSString*_Nonnull)PWD{
    
}
-(void)showCRProposalConfirmView{
    UIView *mainView=[self mainWindow];
    [mainView addSubview:self.CRProposalConfirmV];
    [self.CRProposalConfirmV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(mainView);
    }];
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
        
    });
    
}
-(void)setModel:(HWMBillListModel *)model{
    _model=model;
}
-(NSArray *)cellInfoArray{
    if (!_cellInfoArray) {
        _cellInfoArray =@[NSLocalizedString(@"剩余时间", nil),NSLocalizedString(@"提案哈希", nil),NSLocalizedString(@"原文网址", nil),NSLocalizedString(@"摘要", nil)];
    }
    return _cellInfoArray;
}
-(void)closeCommentPerioDetailsOrOpen:(BOOL)isOpen{
    self.isOpen=!isOpen;
    [self.baseTable reloadData];
}
-(HWMDetailsProposalModel *)DetailsModel{
    if (!_DetailsModel) {
        _DetailsModel=[[HWMDetailsProposalModel alloc]init];
    }
    return _DetailsModel;
}
-(UIView*)setTableViewFootViewWithHeight:(CGFloat)height{
    CGFloat botOff=40;
    if (self.DetailsModel.trackingResult.count==0) {
        botOff=140;
    }
    UIView *foodView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, height)];
    [foodView addSubview:self.foodView];
    [self.foodView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(foodView);
        make.bottom.equalTo(foodView.mas_bottom).mas_offset(-botOff);
    }];
    self.foodView.makeLine.alpha=1.f;
    UILabel *ImplementationScheduleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, height-botOff+20, AppWidth-30, 20)];
    ImplementationScheduleLabel.text=NSLocalizedString(@"执行进度", nil);
    ImplementationScheduleLabel.font=[UIFont systemFontOfSize:14];
    ImplementationScheduleLabel.textColor=[UIColor whiteColor];
    [foodView addSubview:ImplementationScheduleLabel];
 
    if (self.DetailsModel.trackingResult.count==0) {
        UILabel *noLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,  CGRectGetMaxY(ImplementationScheduleLabel.frame), AppWidth-30, 50)];
        noLabel.text=NSLocalizedString(@"暂无执行进度", nil);
        noLabel.font=[UIFont systemFontOfSize:12];
        noLabel.textColor=RGBA(255, 255, 255, 0.5);
        noLabel.textAlignment=NSTextAlignmentCenter;
        
        [foodView addSubview:noLabel];
    }
    return foodView;
}
-(void)CommitteeMembersToVoteISopenOrClose:(BOOL)isClose{
    self.isSecOpen=isClose;
    CGFloat showNw=0;
    if (self.DetailsModel.trackingResult.count==0) {
        showNw=100;
    }
    if (self.isSecOpen) {
        self.secHeight=330+showNw;
    }else{
        self.secHeight=90+showNw;
    }
    [self.baseTable reloadData];
}
-(void)setType:(CommentPerioType)type{
    _type=type;
}
@end
