//
//  NSString+HWMNSTaggedPointerString.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/11/5.
//

#import "NSString+HWMNSTaggedPointerString.h"
#import <objc/runtime.h>
//#import <AppKit/AppKit.h>


@implementation NSString (HWMNSTaggedPointerString)
-(void)count{
    
}

- (NSString *)safeCharacterAtIndex:(NSUInteger)index {
    if (index < self.length) {
        return [NSString stringWithFormat:@"%C",[self characterAtIndex:index]];
    }else {
        return nil;
    }
}

//- (NSString *)safeSubstringFromIndex:(NSUInteger)from {
//  if (from < self.length) {
//    return [self substringFromIndex:from];
//  }else {
//    return nil;
//  }
//}
//
//- (NSString *)safeSubstringToIndex:(NSUInteger)to {
//  if (to < self.length) {
//    return [self substringToIndex:to];
//  }else {
//    return nil;
//  }
//}
//
//- (NSString *)safeSubstringWithRange:(NSRange)range {
//  if (range.location < self.length && range.location + range.length < self.length) {
//    return [self substringWithRange:range];
//  }else {
//    return nil;
//  }
//}
@end
