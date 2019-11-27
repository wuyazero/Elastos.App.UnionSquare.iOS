//
//  HMWVotingListTypeCrossCollectionViewCell.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/6/17.
//

#import "HMWVotingListTypeCrossCollectionViewCell.h"


@interface HMWVotingListTypeCrossCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *contryName;
@property (weak, nonatomic) IBOutlet UILabel *indexLab;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;
@property (weak, nonatomic) IBOutlet UILabel *tickNumberLab;
@property (weak, nonatomic) IBOutlet UIImageView *coinIconImageView;

@end
@implementation HMWVotingListTypeCrossCollectionViewCell


-(void)setModel:(FLCoinPointInfoModel *)model
{
    _model  = model;
    self.nickName.text = model.nickname;
    
    dispatch_group_t group =  dispatch_group_create();
       __block NSString *locationLabelString;
      dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         locationLabelString= [[FLTools share]contryNameTransLateByCode:[model.location intValue]];
       });
      dispatch_group_notify(group, dispatch_get_main_queue(), ^{
             self.contryName.text = locationLabelString;
           
       });
    self.indexLab.text = [@""stringByAppendingString:@(model.index+1).stringValue];
    self.percentLab.text = [NSString stringWithFormat:@"%.5lf %@",model.voterate.floatValue*100,@"%"];
    self.tickNumberLab.text=[NSString stringWithFormat:@"%ld %@",[model.votes longValue],NSLocalizedString(@"票", nil)];
     [self.coinIconImageView sd_setImageWithURL:[NSURL URLWithString:model.iconImageUrl] placeholderImage:[UIImage imageNamed:@"found_vote_initial_oval"]];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [[HMWCommView share]makeBordersWithView:self];
}
-(void)setCRModel:(HWMCRListModel *)CRModel{


        self.nickName.text = CRModel.nickname;
    
    dispatch_group_t group =  dispatch_group_create();
        __block NSString *locationLabelString;
       dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          locationLabelString= [[FLTools share]contryNameTransLateByCode:[CRModel.location intValue]];
        });
       dispatch_group_notify(group, dispatch_get_main_queue(), ^{
              self.contryName.text = locationLabelString;
            
        });    
        self.indexLab.text = [@""stringByAppendingString:@([CRModel.index intValue ]+1).stringValue];
        self.percentLab.text = [NSString stringWithFormat:@"%.5lf %@",CRModel.voterate.floatValue*100,@"%"];
        self.tickNumberLab.text=[NSString stringWithFormat:@"%ld %@",[CRModel.votes longValue],NSLocalizedString(@"票", nil)];
         [self.coinIconImageView sd_setImageWithURL:[NSURL URLWithString:CRModel.url] placeholderImage:[UIImage imageNamed:@"found_vote_initial_oval"]];
    
    _CRModel  = CRModel;
    
    
}
@end
