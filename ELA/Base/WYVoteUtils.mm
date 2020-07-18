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


#import "WYVoteUtils.h"
#import "ELWalletManager.h"
#import "ELACommitteeInfoModel.h"
#import "ELANetwork.h"
#import "HWMCRListModel.h"
#import "FLCoinPointInfoModel.h"
#import "ELACouncilAndSecretariatModel.h"

@implementation WYVoteUtils

+ (NSDictionary *)getVoteInfo:(NSString *)masterWalletID {
    @try {
        IMainchainSubWallet *mainchainSubWallet = [[ELWalletManager share] getWalletELASubWallet:masterWalletID];
        if (mainchainSubWallet) {
            Json json = mainchainSubWallet->GetVoteInfo("");
            NSString *voteInfoString = [[ELWalletManager share] stringWithJson:json];
            NSDictionary *voteInfoDic = @{};
            if(![voteInfoString isEqualToString: @"null"]){
                voteInfoDic=[[ELWalletManager share] dictionaryWithJsonString:voteInfoString];
            }
            WYLog(@"GetVoteInfo success! masterWalletID: %@, voteinfo: %@", masterWalletID, voteInfoDic);
            return voteInfoDic;
        }
        WYLog(@"GetVoteInfo failed! masterWalletID: %@", masterWalletID);
        return nil;
    } @catch (NSException *exception) {
        WYLog(@"GetVoteInfo Exception: %@", exception.reason);
        [[FLTools share] showErrorInfo:exception.reason];
        return nil;
    }
    return nil;
}

+ (NSDictionary *)getVotePayloads:(NSDictionary *)voteInfo {
    @try {
        if (voteInfo) {
            NSMutableDictionary *votePayloads = [[NSMutableDictionary alloc] init];
            votePayloads[@"Delegate"] = @{};
            votePayloads[@"CRC"] = @{};
            votePayloads[@"CRCProposal"] = @{};
            votePayloads[@"CRCImpeachment"] = @{};
            for (id item in voteInfo) {
                votePayloads[item[@"Type"]] = item[@"Votes"];
            }
            WYLog(@"GetVotePayloads success! votePayloads: %@", votePayloads);
            return votePayloads;
        }
        WYLog(@"GetVotePayloads failed! voteInfo: %@", voteInfo);
        return nil;
    } @catch (NSException *exception) {
        WYLog(@"GetVotePayloads Exception: %@", exception.reason);
        [[FLTools share] showErrorInfo:exception.reason];
        return nil;
    }
    return nil;
}

+ (NSDictionary *)getVoteAddrs:(NSDictionary *)votePayloads {
    @try {
        if (votePayloads) {
            NSMutableDictionary *voteAddrs = [[NSMutableDictionary alloc] init];
            for (NSString *key in votePayloads) {
                voteAddrs[key] = [[NSMutableArray alloc] init];
                for (NSString *addr in votePayloads[key]) {
                    [voteAddrs[key] addObject:addr];
                }
            }
            WYLog(@"GetVoteAddrs success! voteAddrs: %@", voteAddrs);
            return voteAddrs;
        }
        WYLog(@"GetVoteAddrs failed! votePayloads: %@", votePayloads);
        return nil;
    } @catch (NSException *exception) {
        WYLog(@"GetVoteAddrs Exception: %@", exception.reason);
        [[FLTools share] showErrorInfo:exception.reason];
        return nil;
    }
    return nil;
}

+ (NSDictionary *)getInvalidAddrs:(NSDictionary *)voteAddrs {
    @try {
        if (voteAddrs) {
            NSMutableDictionary *invalidAddrs = [[NSMutableDictionary alloc] init];
            WYLog(@"dev temp voteAddrs in InvalidAddrs: %@", voteAddrs);
            for (NSString *key in voteAddrs) {
                if ([key isEqualToString:@"Delegate"]) {
                    invalidAddrs[key] = [WYVoteUtils getInvalidDelegates:voteAddrs[key]];
                } else if ([key isEqualToString:@"CRC"]) {
                    invalidAddrs[key] = [WYVoteUtils getInvalidCRCs:voteAddrs[key]];
                } else if ([key isEqualToString:@"CRCProposal"]) {
                    invalidAddrs[key] = [WYVoteUtils getInvalidProposals:voteAddrs[key]];
                } else if ([key isEqualToString:@"CRCImpeachment"]) {
                    invalidAddrs[key] = [WYVoteUtils getInvalidImpeachments:voteAddrs[key]];
                } else {
                    invalidAddrs[key] = @[];
                }
                if (!invalidAddrs[key]) {
                    WYLog(@"GetInvalidAddrs error for key: %@", key);
                    return nil;
                }
            }
            WYLog(@"GetInvalidAddrs success! invalidAddrs: %@", invalidAddrs);
            return invalidAddrs;
        }
        WYLog(@"GetInvalidAddrs failed! voteAddrs: %@", voteAddrs);
        return nil;
    } @catch (NSException *exception) {
        WYLog(@"GetInvalidAddrs Exception: %@", exception.reason);
        [[FLTools share] showErrorInfo:exception.reason];
        return nil;
    }
    return nil;
}

+ (NSArray *)getInvalidDelegates:(NSArray *)delegates {
    dispatch_group_t waitGroup = dispatch_group_create();
    dispatch_queue_t waitQueue = [WYUtils getNetworkQueue];
    
    __block NSArray *DposDataList = nil;
    __block BOOL networkErr = NO;
    dispatch_group_enter(waitGroup);
    dispatch_async(waitQueue, ^{
        NSString *httpIP=[[FLTools share]http_IpFast];
        WYSetUseNetworkQueue(YES);
        [HttpUrl NetPOSTHost:httpIP url:@"/api/dposnoderpc/check/listproducer" header:@{} body:@{@"moreInfo":@"1",@"state":@"all"} showHUD:NO WithSuccessBlock:^(id data) {
            NSDictionary *param = data[@"data"];
            DposDataList =[NSArray modelArrayWithClass:FLCoinPointInfoModel.class json:param[@"result"][@"producers"]];
            dispatch_group_leave(waitGroup);
        } WithFailBlock:^(id data) {
            WYLog(@"%s: Failed to get DposList, error: ", __func__, data[@"code"]);
            networkErr = YES;
            dispatch_group_leave(waitGroup);
        }];
        WYSetUseNetworkQueue(NO);
    });
    
    long status = dispatch_group_wait(waitGroup, dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC * WAIT_TIMEOUT));
    if (status != 0) {
        WYLog(@"%s: getListProducer timeout!!", __func__);
        [[FLTools share] showErrorInfo:@"Network Timeout!!"];
        return nil;
    }
    
    if (networkErr) {
        return nil;
    }
    
    if (DposDataList) {
        NSMutableArray *invalidDelegates = [[NSMutableArray alloc] init];
        for (NSString *key in delegates) {
            BOOL keyFound = NO;
            for (FLCoinPointInfoModel *DposData in DposDataList) {
                if ([DposData.ownerpublickey isEqualToString:key]) {
                    keyFound = YES;
                    if (![DposData.state isEqualToString:@"Active"]) {
                        [invalidDelegates addObject:key];
                    }
                    break;
                }
            }
            if (!keyFound) {
                [invalidDelegates addObject:key];
            }
        }
        return invalidDelegates;
    }
    
    return delegates;
}

+ (NSArray *)getInvalidCRCs:(NSArray *)crcs {
    dispatch_group_t waitGroup = dispatch_group_create();
    dispatch_queue_t waitQueue = [WYUtils getNetworkQueue];
    
    __block ELACommitteeInfoModel *CRCVotingInfo = nil;
    __block NSArray *CRCDataList = nil;
    __block BOOL networkErr = NO;
    dispatch_group_enter(waitGroup);
    dispatch_group_enter(waitGroup);
    dispatch_async(waitQueue, ^{
        WYSetUseNetworkQueue(YES);
        [ELANetwork getCommitteeInfo:^(id  _Nonnull data, NSError * _Nonnull error) {
            if (error) {
                WYLog(@"%s: getCommitteeInfo failed with error code %ld", __func__, error.code);
                [[FLTools share] showErrorInfo:error.localizedDescription];
                networkErr = YES;
            } else {
                CRCVotingInfo = data;
            }
            dispatch_group_leave(waitGroup);
        }];
        WYSetUseNetworkQueue(NO);
        
        NSString *httpIP=[[FLTools share]http_IpFast];
        WYSetUseNetworkQueue(YES);
        [HttpUrl NetPOSTHost:httpIP url:@"/api/dposnoderpc/check/listcrcandidates" header:@{} body:@{@"state":@"all"} showHUD:NO WithSuccessBlock:^(id data) {
            NSDictionary *param = data[@"data"];
            CRCDataList = [NSArray modelArrayWithClass:HWMCRListModel.class json:param[@"result"][@"crcandidatesinfo"]];
            dispatch_group_leave(waitGroup);
        } WithFailBlock:^(id data) {
            WYLog(@"%s: Failed to get CRCList, error: ", __func__, data[@"code"]);
            networkErr = YES;
            dispatch_group_leave(waitGroup);
        }];
        WYSetUseNetworkQueue(NO);
    });
    
    long status = dispatch_group_wait(waitGroup, dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC * WAIT_TIMEOUT));
    if (status != 0) {
        WYLog(@"%s: getCommitteeInfo timeout!!", __func__);
        [[FLTools share] showErrorInfo:@"Network Timeout!!"];
        return nil;
    }
    
    if (networkErr) {
        return nil;
    }
    
    if (CRCVotingInfo) {
        if ([WYVoteUtils isCRCVoting:CRCVotingInfo.data] && CRCDataList) {
            NSMutableArray *invalidCRCs = [[NSMutableArray alloc] init];
            for (NSString *did in crcs) {
                BOOL didFound = NO;
                for (HWMCRListModel *CRCData in CRCDataList) {
                    if ([CRCData.did isEqualToString:did]) {
                        didFound = YES;
                        if (![CRCData.state isEqualToString:@"Active"]) {
                            [invalidCRCs addObject:did];
                        }
                        break;
                    }
                }
                if (!didFound) {
                    [invalidCRCs addObject:did];
                }
            }
            return invalidCRCs;
        }
        return crcs;
    } else {
        WYLog(@"%s: CRCVotingInfo Empty!!", __func__);
    }
    return crcs;
}

+ (BOOL)isCRCVoting:(NSArray *)data {
    for(ELACommitteeInfoModel *item in data) {
        if(item.status && [item.status isEqualToString:@"VOTING"]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)getInvalidProposals:(NSArray *)proposals {
    dispatch_group_t waitGroup = dispatch_group_create();
    dispatch_queue_t waitQueue = [WYUtils getNetworkQueue];
    
    __block NSArray *proposalDataList = nil;
    __block BOOL networkErr = NO;
    dispatch_group_enter(waitGroup);
    dispatch_async(waitQueue, ^{
        WYSetUseNetworkQueue(YES);
        [ELANetwork cvoteAllSearch:@"" page:0 results:100 type:NOTIFICATIONType block:^(id  _Nonnull data, NSError * _Nonnull error){
            if (error) {
                WYLog(@"%s: getProposalDataList failed with error code %ld", __func__, error.code);
                [[FLTools share] showErrorInfo:error.localizedDescription];
                networkErr = YES;
            } else {
                if (data[@"data"]) {
                    proposalDataList = data[@"data"][@"list"];
                }
            }
            dispatch_group_leave(waitGroup);
        }];
        WYSetUseNetworkQueue(NO);
    });
    
    long status = dispatch_group_wait(waitGroup, dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC * WAIT_TIMEOUT));
    if (status != 0) {
        WYLog(@"%s: getProposalList timeout!!", __func__);
        [[FLTools share] showErrorInfo:@"Network Timeout!!"];
        return nil;
    }
    
    if (networkErr) {
        return nil;
    }
    
    if (proposalDataList) {
        NSMutableArray *invalidProposals = [[NSMutableArray alloc] init];
        for (NSString *pHash in proposals) {
            BOOL hashFound = NO;
            for (NSDictionary *proposalData in proposalDataList) {
                if ([proposalData[@"proposalHash"] isEqualToString:pHash]) {
                    hashFound = YES;
                    if (![proposalData[@"status"] isEqualToString:@"NOTIFICATION"]) {
                        [invalidProposals addObject:pHash];
                    }
                    break;
                }
            }
            if (!hashFound) {
                [invalidProposals addObject:pHash];
            }
        }
        return invalidProposals;
    }
    return proposals;
}

+ (NSArray *)getInvalidImpeachments:(NSArray *)impeachments {
    dispatch_group_t waitGroup = dispatch_group_create();
    dispatch_queue_t waitQueue = [WYUtils getNetworkQueue];
    
    __block NSArray *councilDataList = nil;
    __block BOOL networkErr = NO;
    dispatch_group_enter(waitGroup);
    dispatch_async(waitQueue, ^{
        WYSetUseNetworkQueue(YES);
        [ELANetwork getCommitteeInfo:^(id  _Nonnull data, NSError * _Nonnull error) {
            if (error) {
                WYLog(@"%s: getCommitteeInfo failed with error code %ld", __func__, error.code);
                [[FLTools share] showErrorInfo:error.localizedDescription];
                networkErr = YES;
                dispatch_group_leave(waitGroup);
            } else {
                ELACommitteeInfoModel *CRCInfo = data;
                NSInteger index = [WYVoteUtils getCurrentCRCIndex:CRCInfo.data];
                if (index) {
                    WYSetUseNetworkQueue(YES);
                    [ELANetwork getCouncilListInfo:index block:^(id  _Nonnull data, NSError * _Nonnull error) {
                        if (error) {
                            WYLog(@"%s: getCouncilList failed with error code %ld", __func__, error.code);
                            [[FLTools share] showErrorInfo:error.localizedDescription];
                            networkErr = YES;
                        } else {
                            ELACouncilAndSecretariatModel *councilAndSecretariatInfo = data;
                            councilDataList = councilAndSecretariatInfo.council;
                        }
                        dispatch_group_leave(waitGroup);
                    }];
                    WYSetUseNetworkQueue(NO);
                } else {
                    dispatch_group_leave(waitGroup);
                }
            }
        }];
        WYSetUseNetworkQueue(NO);
    });
    
    long status = dispatch_group_wait(waitGroup, dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC * WAIT_TIMEOUT));
    if (status != 0) {
        WYLog(@"%s: getCouncilList timeout!!", __func__);
        [[FLTools share] showErrorInfo:@"Network Timeout!!"];
        return nil;
    }
    
    if (networkErr) {
        return nil;
    }
    
    if (councilDataList) {
        NSMutableArray *invalidImpeachments = [[NSMutableArray alloc] init];
        for (NSString *cid in impeachments) {
            BOOL cidFound = NO;
            for (ELACouncilModel *councilData in councilDataList) {
                if ([councilData.cid isEqualToString:cid]) {
                    cidFound = YES;
                    if (![councilData.status isEqualToString:@"Elected"]) {
                        [invalidImpeachments addObject:cid];
                    }
                    break;
                }
            }
            if (!cidFound) {
                [invalidImpeachments addObject:cid];
            }
        }
        return invalidImpeachments;
    }
    return impeachments;
}

+ (NSInteger)getCurrentCRCIndex:(NSArray *)data {
    for(ELACommitteeInfoModel *item in data) {
        if(item.status && [item.status isEqualToString:@"CURRENT"]) {
            return item.index;
        }
    }
    return NO;
}

+ (NSDictionary *)getValidPayloads:(NSDictionary *)payloads withInvalidAddrs:(NSDictionary *)invalidAddrs {
    @try {
        if (payloads) {
            NSMutableDictionary *validPayloads = [[NSMutableDictionary alloc] init];
            for (NSString *key in payloads) {
                validPayloads[key] = [[NSMutableDictionary alloc] init];
                for (NSString *addr in payloads[key]) {
                    if (![invalidAddrs[key] containsObject:addr]) {
                        validPayloads[key][addr] = payloads[key][addr];
                    }
                }
            }
            WYLog(@"GetValidPayloads success! validPayloads: %@", validPayloads);
            return validPayloads;
        }
        WYLog(@"GetValidPayload failed! payloads: %@", payloads);
        return nil;
    } @catch (NSException *exception) {
        WYLog(@"GetValidPayloads Exception: %@", exception.reason);
        [[FLTools share] showErrorInfo:exception.reason];
        return nil;
    }
    return nil;
}

+ (NSDictionary *)mergePayloads:(NSDictionary *)curPayloads withPayloads:(NSDictionary *)prevPayloads {
    NSMutableDictionary *mergedPayloads = [[NSMutableDictionary alloc] init];
    for (NSString *key in curPayloads) {
        mergedPayloads[key] = curPayloads[key];
    }
    for (NSString *key in prevPayloads) {
        if (!mergedPayloads[key]) {
            mergedPayloads[key] = prevPayloads[key];
        }
    }
    return mergedPayloads;
}

+ (NSDictionary *)prepareVoteInfo:(NSString *)masterWalletID {
    NSDictionary *voteInfo = [WYVoteUtils getVoteInfo:masterWalletID];
    if (!voteInfo) {
        return nil;
    }
    NSDictionary *votePayloads = [WYVoteUtils getVotePayloads:voteInfo];
    if (!votePayloads) {
        return nil;
    }
    NSDictionary *voteAddrs = [WYVoteUtils getVoteAddrs:votePayloads];
    if (!voteAddrs) {
        return nil;
    }
    NSDictionary *invalidAddrs = [WYVoteUtils getInvalidAddrs:voteAddrs];
    if (!invalidAddrs) {
        return nil;
    }
    NSDictionary *validPayloads = [WYVoteUtils getValidPayloads:votePayloads withInvalidAddrs:invalidAddrs];
    if (!validPayloads) {
        return nil;
    }
    NSMutableArray *invalidCandidates = [[NSMutableArray alloc] init];
    for (NSString *key in invalidAddrs) {
        [invalidCandidates addObject:@{
            @"Type": key,
            @"Candidates": invalidAddrs[key]
        }];
    }
    return @{
        @"validPayloads": validPayloads,
        @"invalidCandidates": invalidCandidates
    };
}

+ (NSDictionary *)createDelegateVote:(NSDictionary *)votes withWallet:(NSString *)masterWalletID {
    NSDictionary *voteInfo = [WYVoteUtils prepareVoteInfo:masterWalletID];
    if (!voteInfo) {
        return nil;
    }
    return @{
        @"votePayloads": votes,
        @"invalidCandidates": voteInfo[@"invalidCandidates"]
    };
}

+ (NSDictionary *)createCRCVote:(NSDictionary *)votes withWallet:(NSString *)masterWalletID {
    NSDictionary *voteInfo = [WYVoteUtils prepareVoteInfo:masterWalletID];
    if (!voteInfo) {
        return nil;
    }
    return @{
        @"votePayloads": votes,
        @"invalidCandidates": voteInfo[@"invalidCandidates"]
    };
}

+ (NSDictionary *)createProposalVote:(NSDictionary *)votes withWallet:(NSString *)masterWalletID {
    NSDictionary *voteInfo = [WYVoteUtils prepareVoteInfo:masterWalletID];
    if (!voteInfo) {
        return nil;
    }
    NSDictionary *votePayloads = [WYVoteUtils mergePayloads:votes withPayloads:voteInfo[@"validPayloads"][@"CRCProposal"]];
    return @{
        @"votePayloads": votePayloads,
        @"invalidCandidates": voteInfo[@"invalidCandidates"]
    };
}

+ (NSDictionary *)createImpeachmentVote:(NSDictionary *)votes withWallet:(NSString *)masterWalletID {
    NSDictionary *voteInfo = [WYVoteUtils prepareVoteInfo:masterWalletID];
    if (!voteInfo) {
        return nil;
    }
    NSDictionary *votePayloads = [WYVoteUtils mergePayloads:votes withPayloads:voteInfo[@"validPayloads"][@"CRCImpeachment"]];
    return @{
        @"votePayloads": votePayloads,
        @"invalidCandidates": voteInfo[@"invalidCandidates"]
    };
}

@end
