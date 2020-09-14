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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWMadviceModel : NSObject
/*
 *
 */
@property(copy,nonatomic)NSString *ID;

@property(copy,nonatomic)NSString *status;
@property(copy,nonatomic)NSString *type;

@property(copy,nonatomic)NSString *targetProposalTitle;
@property(copy,nonatomic)NSString *closeProposalNum;
@property(copy,nonatomic)NSString *targetProposalNum;
@property(copy,nonatomic)NSString *NewAddress;
@property(copy,nonatomic)NSString *NewSecretaryDID;
@property(copy,nonatomic)NSString *NewOwnerDID;
/*
 *
 */
@property(copy,nonatomic)NSString * title;
/*
 *
 */
@property(copy,nonatomic)NSString * did;
/*
 *
 */
@property(copy,nonatomic)NSString * didName;
@property(copy,nonatomic)NSString * abs;
@property(copy,nonatomic)NSString * address;
@property(assign,nonatomic)NSString * createdAt;
@property(copy,nonatomic)NSString * baseInfoString;
@property(assign,nonatomic)CGFloat  baseInfoCell;
@property(assign,nonatomic)CGFloat  absCell;
@property(assign,nonatomic)CGFloat  targetTitleCell;
@end

NS_ASSUME_NONNULL_END
