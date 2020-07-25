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


#import "WYContactListViewController.h"
#import "HMWFMDBManager.h"
#import "HMWmyContactListTableViewCell.h"
#import "friendsModel.h"
#import "HMWtheContactInformationViewController.h"
#import "HMWaddContactViewController.h"

static NSString *theContactCell=@"HMWmyContactListTableViewCell";

@interface WYContactListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *table;

@property(strong,nonatomic)NSMutableArray *theContactMutableArray;

@end

@implementation WYContactListViewController

- (void)loadView {
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.table  = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.table registerNib:[UINib nibWithNibName:theContactCell bundle:nil] forCellReuseIdentifier:theContactCell];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    UIImageView *bgview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self CAGradientColorFrome:RGB(83, 136, 136) withToColor:RGB(16, 47, 58) withView:bgview];
    self.table.backgroundView = bgview;
    self.table.rowHeight = 60;
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AppWidth, 40)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    if (self.theContactMutableArray.count > 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"add_contact"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(addContact)];
    }
    [self setBackgroundImg:@""];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.table reloadData];
}

- (void)addContact {
    HMWaddContactViewController *addContactVC=[[HMWaddContactViewController alloc]init];
    addContactVC.title=NSLocalizedString(@"添加联系人", nil);
    addContactVC.typeInfo=updateInfo;
    [self.navigationController pushViewController:addContactVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.theContactMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HMWmyContactListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:theContactCell];
    
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    friendsModel *model=self.theContactMutableArray[indexPath.row];
    cell.nickNameLabel.text=model.nameString;
    cell.BGView.layer.borderColor = [UIColor clearColor].CGColor;
    cell.BGView.backgroundColor = RGB(97, 139, 143);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HMWtheContactInformationViewController *theContactInformationVC=[[HMWtheContactInformationViewController alloc]init];
    theContactInformationVC.model=self.theContactMutableArray[indexPath.row];
    [self.navigationController pushViewController:theContactInformationVC animated:YES];
}

- (NSMutableArray *)theContactMutableArray {
    
    if (!_theContactMutableArray) {
        _theContactMutableArray =[[NSMutableArray alloc]initWithArray:[[HMWFMDBManager sharedManagerType:friendsModelType]allRecord]];
    }
    return _theContactMutableArray;
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
