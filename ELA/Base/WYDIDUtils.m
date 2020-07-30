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


#import "WYDIDUtils.h"
#import "ela_did.h"

@implementation WYDIDUtils

+ (NSString *)validateDIDString:(NSString *)DIDString {
    if (![DIDString hasPrefix:@"did:elastos:"]) {
        DIDString = [NSString stringWithFormat:@"%@%@", @"did:elastos:", DIDString];
    }
    if (![DIDString hasPrefix:@"did:elastos:i"] || DIDString.length != 46) {
        return nil;
    }
    NSString *bodyString = [DIDString substringFromIndex:12];
    if ([WYUtils matchString:bodyString withRegex:@"[A-Z0-9a-z]+"]) {
        return DIDString;
    }
    return nil;
}

+ (NSDictionary *)getDIDInfoFromString:(NSString *)DIDString {
    const char *DIDCString = [DIDString UTF8String];
    DID *did = DID_FromString(DIDCString);
    DIDDocument *doc = DID_Resolve(did, true);
    if (doc) {
        DIDURL *url = DIDURL_NewByDid(did, "name");
        time_t endTime = DIDDocument_GetExpires(doc);
        Credential *cred = DIDDocument_GetCredential(doc, url);
        const char *didCName = Credential_GetProperty(cred, "name");
        NSString *didName = (didCName == NULL) ? nil : [NSString stringWithUTF8String:didCName];
        NSString *endTimeString=[[FLTools share]SpecialTimeZoneConversion:[NSString stringWithFormat:@"%@",@(endTime)]];
        NSDictionary *result = @{
            @"didName": didName,
            @"endTime": endTimeString,
            @"DIDString": DIDString
        };
        DIDURL_Destroy(url);
        DIDDocument_Destroy(doc);
        DID_Destroy(did);
        return result;
    }
    DIDDocument_Destroy(doc);
    DID_Destroy(did);
    return nil;
}

@end
