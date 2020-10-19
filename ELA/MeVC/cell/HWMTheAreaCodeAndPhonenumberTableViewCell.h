//
//  HWMTheAreaCodeAndPhonenumberTableViewCell.h
//  elastos wallet
//
//  Created by  on 2019/10/25.
//

#import <UIKit/UIKit.h>

@protocol HWMTheAreaCodeAndPhonenumberTableViewCellDelegate <NSObject>

-(void)delegateViewWithDic:(NSDictionary*)dic;

- (void)deleteWithIndex:(NSString* _Nullable)index;

@end

@interface HWMTheAreaCodeAndPhonenumberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *theArNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *MobilePhoneTextField;
@property(weak,nonatomic)id<HWMTheAreaCodeAndPhonenumberTableViewCellDelegate> delegate;
@property(copy,nonatomic)NSDictionary *dic;
@property(copy,nonatomic)NSString *index;
@end


