//
//  HWMDIDInfoTableViewCell.h
//  elastos wallet
//
//  Created by  on 2019/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWMDIDInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *longInfoLabel;
@end

NS_ASSUME_NONNULL_END
