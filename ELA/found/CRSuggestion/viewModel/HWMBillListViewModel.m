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


#import "HWMBillListViewModel.h"
#import "HWMBillListModel.h"
@interface HWMBillListViewModel (){
    dispatch_queue_t  Analyticalqueue_t;
    
}

@end
@implementation HWMBillListViewModel
-(instancetype)init{
    self= [super init];
    if (self) {
        Analyticalqueue_t=dispatch_queue_create("HWMBillListViewModel",DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}
-(void)BillListWithDataJosn:(id)json completion:(_Nonnull BillListBlock)completionBlock {
    dispatch_async(Analyticalqueue_t, ^{
        NSArray *dataArray= [self AnalyticalDataWithDicJosn:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(dataArray);
            
        });
    });
}
-(NSArray*)AnalyticalDataWithDicJosn:(id)json{
    NSArray *modeArray=[NSArray modelArrayWithClass:[HWMBillListModel class] json:json];
    NSMutableArray *AnalyticalArray=[[NSMutableArray alloc]init];
    for (HWMBillListModel *model in modeArray) {
        NSString* proposedBy = [self nullToString:model.proposedBy];
        model.baseInfoString=[NSString stringWithFormat:@"#%@ %@ %@",model.ID ,[[FLTools share]TimeFormatConversionBirthday:model.createdAt],proposedBy]; 
        if (self.searchString) {
            model.searchRanege=[model.title localizedStandardRangeOfString:self.searchString];
        }
        if ([model.status isEqualToString:@"VOTING"]) {
            model.status=NSLocalizedString(@"委员评议",nil);
        }else if ([model.status isEqualToString:@"NOTIFICATION"]){
            model.status=NSLocalizedString(@"公示中",nil);
        }else if ([model.status isEqualToString:@"ACTIVE"]){
            model.status=NSLocalizedString(@"执行中",nil);
        }else if ([model.status isEqualToString:@"FINAL"]){
            model.status=NSLocalizedString(@"已完成",nil);
        }else if ([model.status isEqualToString:@"REJECTED"]){
            model.status=NSLocalizedString(@"未通过",nil);
        }else if ([model.status isEqualToString:@"VETOED"]){
            model.status=NSLocalizedString(@"已否决",nil);
        }
        
        if ([model.type isEqualToString:@"normal"]) {
            model.type=NSLocalizedString(@"新动议",nil);
        }else if ([model.type isEqualToString:@"closeproposal"]){
            model.type=NSLocalizedString(@"终止提案动议",nil);
        }else if ([model.type isEqualToString:@"changeproposalowner"]){
            model.type=NSLocalizedString(@"变更提案动议",nil);
        }else if ([model.type isEqualToString:@"secretarygeneral"]){
            model.type=NSLocalizedString(@"变更秘书长动议",nil);
        }
        
        model.cellHeight=[[FLTools share]calculateRowHeight:model.title fontSize:14 withmargin:30];
        if (model.cellHeight>60) {
            model.lastCellHeight=60;
        }else{
            model.lastCellHeight=model.cellHeight;
        }
        [AnalyticalArray addObject:model];
    }
    return AnalyticalArray;
}

- (NSString *)nullToString:(id)string {
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"]) {
        return @"";
    } else {
        return (NSString *)string;
    }
}


@end
