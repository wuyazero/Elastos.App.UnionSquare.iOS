//
//  HWMConfidentialInformationViewController.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/10/31.
//

#import "HWMConfidentialInformationViewController.h"
#import "HWMDIDListAbnormalTableViewCell.h"
static NSString *normalCellString=@"HWMDIDListAbnormalTableViewCell";
@interface HWMConfidentialInformationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIButton *TheImportButton;

@property(copy,nonatomic)NSArray *dataArray;
@end

@implementation HWMConfidentialInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title=NSLocalizedString(@"凭证信息", nil);
    [self.TheImportButton setTitle:NSLocalizedString(@"导入", nil) forState:UIControlStateNormal];
    [self.exportButton setTitle:NSLocalizedString(@"导出", nil) forState:UIControlStateNormal];
    
    
    [self makeUI];
}
-(NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray =@[@"个人信息",@"个人简介",@"社交账号"];
    }
    return _dataArray;
}
-(void)makeUI{

    
  
    [self.table registerNib:[UINib nibWithNibName:normalCellString bundle:nil] forCellReuseIdentifier:normalCellString];
        [self.table registerNib:[UINib nibWithNibName:normalCellString bundle:nil] forCellReuseIdentifier:normalCellString];
       self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
     self.table.rowHeight = 70;
       self.table.delegate =self;
       self.table.dataSource =self;
    self.table.backgroundColor=[UIColor clearColor];

    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // FLSugarModel *model = self.dataSouse[indexPath.row];
   HWMDIDListAbnormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellString];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.model=self.model;
    cell.titleString=self.dataArray[indexPath.section];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return self.dataArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
                      
        break;
        case 2:
                      
        break;
            
        default:
            break;
    }

}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    
    return 10.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (IBAction)exportEvent:(id)sender {
}
- (IBAction)TheImportEvent:(id)sender {
}
-(void)setModel:(HWMDIDInfoModel *)model{
    _model=model;
}
@end
