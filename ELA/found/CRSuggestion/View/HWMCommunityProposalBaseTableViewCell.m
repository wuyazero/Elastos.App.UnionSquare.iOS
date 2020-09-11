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


#import "HWMCommunityProposalBaseTableViewCell.h"
#import "YYKit.h"

@interface HWMCommunityProposalBaseTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabte;

@end

@implementation HWMCommunityProposalBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)setModel:(HWMBillListModel *)model{
    self.titleLabel.text=model.title;
    self.rightLabte.text=model.type;
    self.leftLabel.text=model.baseInfoString;
    _model=model;
    if (self.isSearch) {
        [self setSearchTestColorString];
}
}
-(void)setSearchTestColorString{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.model.title];
    text.font = [UIFont boldSystemFontOfSize:14];
    text.color = [UIColor whiteColor];
    [text addAttribute:NSBackgroundColorAttributeName value:RGBA(255, 255, 255, 0.5)
     range:self.model.searchRanege];
    self.titleLabel .attributedText = text;
}
@end
