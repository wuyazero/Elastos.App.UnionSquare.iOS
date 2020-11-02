//
//  ElasubWalletCallback.m
//  elastos wallet
//
//  Created by  on 2019/1/21.
//

#import "ElaSubWalletCallback.h"
#import "ELWalletManager.h"
#include <wchar.h>
#import "HWMMessageCenterModel.h"
#import "HMWFMDBManager.h"


NSString *wallID;
//
using namespace Elastos::ElaWallet;

//@implementation ElaSubWalletCallback

ElaSubWalletCallback::ElaSubWalletCallback(const std::string &callBackInfo){
    _callBackInfo=callBackInfo;
}
ElaSubWalletCallback::~ElaSubWalletCallback(){
    
}
void ElaSubWalletCallback::OnTransactionStatusChanged(
                                                      const std::string &txid,
                                                      const std::string &status,
                                                      const nlohmann::json &desc,
                                                      uint32_t confirms){
    NSString *txidString=[NSString stringWithUTF8String:txid.c_str()];
    //    NSDictionary *dic=@{@"txid":txidString,
    //                        @"status":[NSString stringWithUTF8String:status.c_str()],
    //                        @"desc":[NSString stringWithUTF8String:desc.dump().c_str()],@"desc":[NSString stringWithUTF8String:desc.dump().c_str()],
    //                        @"confirms":@(confirms)
    //    };
//    if (confirms!=0) {
//
//        NSString *walletInfo= [NSString stringWithCString:_callBackInfo.c_str() encoding:NSUTF8StringEncoding];
//        NSArray *infoArray=[[FLTools share]stringToArray:walletInfo];
//        NSString *walletID=infoArray.firstObject;
//        NSString *chainID=infoArray[1];
//        HWMMessageCenterModel *model =[[HWMMessageCenterModel alloc]init];
//        model.walletID= walletID;
//        model.chainID=chainID;
//        model.typeHash=txidString;
//        HWMMessageCenterModel *almodel=[[HMWFMDBManager sharedManagerType:transactionsType]selectTransactionsWithModel:model];
//        if ([almodel.MessageType isEqualToString:@"1001"]) {
//            model.MessageC=@"由于交易金额不足,您的CR委员选举投票已失效";
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [[FLTools share]showNeMessageWith:model];
//            });
//        }else if ([almodel.MessageType isEqualToString:@"1002"]){
//             model.MessageC=@"由于交易金额不足,您的超级节点选举投票已失效";
//
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                [[FLTools share]showNeMessageWith:model];
//            });
//        }
        
//    }
}

//void ElaSubWalletCallback::OnBlockSyncStarted()
//{
//
//}

void ElaSubWalletCallback::OnBlockSyncProgress(const nlohmann::json &progressInfo)
{
    NSString *walletIDString = [NSString stringWithCString:_callBackInfo.c_str() encoding:NSUTF8StringEncoding];
    NSString *progressInfoString=[NSString stringWithCString:progressInfo.dump().c_str() encoding:NSUTF8StringEncoding];
    NSDictionary *progressInfoDic=[[FLTools share]dictionaryWithJsonString:progressInfoString];
    
    NSString *BytesPerSecond=[NSString stringWithFormat:@"%@",progressInfoDic[@"BytesPerSecond"]];
    NSString *Progress=[NSString stringWithFormat:@"%f",[progressInfoDic[@"Progress"] doubleValue]/100];
    NSString *DownloadPeer=[NSString stringWithFormat:@"%@",progressInfoDic[@"DownloadPeer"]];
    NSString *LastBlockTime=[NSString stringWithFormat:@"%@",progressInfoDic[@"LastBlockTime"]];
    
    NSDictionary *dic=@{@"progress":Progress,@"callBackInfo":walletIDString,@"lastBlockTimeString":LastBlockTime,@"BytesPerSecond":BytesPerSecond,@"DownloadPeer":DownloadPeer};
    [[NSNotificationCenter defaultCenter] postNotificationName:progressBarcallBackInfo object:dic];
}
void ElaSubWalletCallback::OnBalanceChanged(const std::string &asset, const std::string &balance){
    NSString *walletIDString = [NSString stringWithCString:_callBackInfo.c_str() encoding:NSUTF8StringEncoding];
    NSString *assetString = [NSString stringWithCString:asset.c_str() encoding:NSUTF8StringEncoding];
    
    NSDictionary *dic=@{@"asset":assetString,@"balance":[NSString stringWithCString:balance.c_str() encoding:NSUTF8StringEncoding],@"callBackInfo":walletIDString};
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountBalanceChanges object:dic];
}

//xxl #943
void ElaSubWalletCallback::OnTxPublished(const std::string &hash, const nlohmann::json &result)
{
    NSString *hashString = [NSString stringWithCString:hash.c_str() encoding:NSUTF8StringEncoding];
    NSString *resultString = [NSString stringWithCString:result.dump().c_str() encoding:NSUTF8StringEncoding];
    
    WYLog(@"xxl 943 1 ElaSubWalletCallback " );
    NSDictionary *dic=[[FLTools share]dictionaryWithJsonString:resultString];
    WYLog(@"%@",dic);
    if (dic) {
        int code= [dic[@"Code"] intValue];
        //if (code==0||(code==18&& [dic[@"Reason"] isEqualToString:@"uplicate"])){
        if (code==0 && [dic[@"Reason"] isEqualToString:@"success"]){
            WYLog(@"xxl 943 1 OK ElaSubWalletCallback %@",dic);
            [[NSNotificationCenter defaultCenter] postNotificationName:OnTxPublishedResult object:dic];

        }else if(code != 0){
            WYLog(@"xxl 943 1 error ElaSubWalletCallback %@",dic);
            
            NSString *walletInfo= [NSString stringWithCString:_callBackInfo.c_str() encoding:NSUTF8StringEncoding];
            NSArray *infoArray=[[FLTools share]stringToArray:walletInfo];
            NSString *walletID=infoArray.firstObject;
            NSString *chainID=infoArray[1];
            HWMMessageCenterModel *model =[[HWMMessageCenterModel alloc]init];
            model.walletID= walletID;
            model.chainID=chainID;
            model.MessageC=NSLocalizedString(@"交易错误，无法上链", nil);
            model.typeHash=hashString;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[FLTools share]showNeMessageWith:model];
                
                [SVProgressHUD dismiss];
            });
        }

    }
    
    
}

/**
 * Callback method fired when block end synchronizing with a peer. This callback could be used to show progress.
 */
void ElaSubWalletCallback::OnAssetRegistered(const std::string &asset, const nlohmann::json &info){
    
    
}
void ElaSubWalletCallback::OnConnectStatusChanged(const std::string &status){
    NSString *walletIDString = [NSString stringWithCString:_callBackInfo.c_str() encoding:NSUTF8StringEncoding];
    NSDictionary *dic=@{@"status":[NSString stringWithCString:status.c_str() encoding:NSUTF8StringEncoding],@"callBackInfo":walletIDString};
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectStatusChanged object:dic];
    
}

void ElaSubWalletCallback::OnETHSCEventHandled(const nlohmann::json &event) {
    
}

/**
 * @param id request id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": "0x1dfd14000" // 8049999872 Wei
 * }
 */
nlohmann::json ElaSubWalletCallback::GasPrice(int id) {
    nlohmann::json j;
    // rpc request
    // ...
    j["id"] = id;
    j["result"] = "0x1dfd14000";
    return j;
}

/**
 * @param from
 * @param to
 * @param amount
 * @param gasPrice
 * @param data
 * @param id request id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": "0x5208" // 21000
 * }
 */
nlohmann::json ElaSubWalletCallback::EstimateGas(const std::string &from,
                                   const std::string &to,
                                   const std::string &amount,
                                   const std::string &gasPrice,
                                   const std::string &data,
                                                 int id) {
    nlohmann::json j;
    // rpc request
    // ...
    j["id"] = id;
    j["result"] = "0x5208";
    return j;
}

/**
 * @param address
 * @param id
 * @return
 * {
 *   "id": 0,
 *   "result": "0x0234c8a3397aab58" // 158972490234375000
 * }
 */
nlohmann::json ElaSubWalletCallback::GetBalance(const std::string &address, int id) {
    nlohmann::json j;
    // rpc request
    j["id"] = id;
    j["result"] = "0x0234c8a3397aab58";
    return j;
}

/**
 * @param tx Signed raw transaction.
 * @param id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331"
 * }
 */
nlohmann::json ElaSubWalletCallback::SubmitTransaction(const std::string &tx, int id) {
    nlohmann::json j;
    // rpc request
    j["id"] = id;
    j["result"] = "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331";
    return j;
}

/**
 * @param begBlockNumber
 * @param endBlockNumber
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": [{
 *     "hash":"0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b",
 *     "from":"0xa7d9ddbe1f17865597fbd27ec712455208b6b76d",
 *     "to":"0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb",
 *     "contract":"0xb60e8dd61c5d32be8058bb8eb970870f07233155", // or "", if none was created
 *     "amount":"0xf3dbb76162000", // 4290000000000000
 *     "gasLimit":"0x1388",
 *     "gasPrice":"0x4a817c800", // 20000000000
 *     "data":"0x68656c6c6f21", // input
 *     "nonce":"0x15", // 21
 *     "gasUsed":"0xc350", // 50000
 *     "blockNumber":"0x5daf3b", // 6139707
 *     "blockHash":"0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2",
 *     "blockConfirmations":"0x100", // 256
 *     "blockTransactionIndex":"0x41", // 65
 *     "blockTimestamp":"0x55ba467c",
 *     "isError": "0"
 *   },
 *   {
 *     ...
 *   }]
 * }
 */
nlohmann::json ElaSubWalletCallback::GetTransactions(const std::string &address,
                                       uint64_t begBlockNumber,
                                       uint64_t endBlockNumber,
                                                     int id) {
    nlohmann::json j, txns = nlohmann::json::array(), tx;

    // rpc request
    // ...
    tx["hash"] = "0xe7b3134cb1eb3bc69978fa4f2793f3f49f931a3d863831fc2f56437eb4f6f322";
    tx["from"] = "0x53781e106a2e3378083bdcede1874e5c2a7225f8";
    tx["to"] = "0xd2fbb995bd917d0f6655f41c4006cc58da7603df";
    tx["contract"] = ""; // or "", if none was created
    tx["amount"] = "999999999999999999"; // 4290000000000000
    tx["gasLimit"] = "5012644";
    tx["gasPrice"] = "1000000000"; // 20000000000
    tx["data"] = ""; // input
    tx["nonce"] = "0"; // 21
    tx["gasUsed"] = "21000"; // 50000
    tx["blockNumber"] = "66"; // 6139707
    tx["blockHash"] = "0xcff4a5a940982f991ee5c82d28643582d77a23d28edee794e4392f105cad203d";
    tx["blockConfirmations"] = "76611"; // 256
    tx["blockTransactionIndex"] = "0"; // 65
    tx["blockTimestamp"] = "1598498146";
    tx["isError"] = "0";

    txns.push_back(tx);

    tx["hash"] = "0x67a77b8bd2a24481f2aaa916ed7587aeedf39ee7e41b9d321bea021cb1edea14";
    tx["from"] = "0x53781e106a2e3378083bdcede1874e5c2a7225f8";
    tx["to"] = "0xd2fbb995bd917d0f6655f41c4006cc58da7603df";
    tx["contract"] = ""; // or "", if none was created
    tx["amount"] = "1000000000000000000"; // 4290000000000000
    tx["gasLimit"] = "8000000";
    tx["gasPrice"] = "1000000000"; // 20000000000
    tx["data"] = ""; // input
    tx["nonce"] = "1"; // 21
    tx["gasUsed"] = "21000"; // 50000
    tx["blockNumber"] = "572"; // 6139707
    tx["blockHash"] = "0x991753835922fad42de10f64f840eeca3d42dcbd4c95294dcabd6b2403fb2b46";
    tx["blockConfirmations"] = "76105"; // 256
    tx["blockTransactionIndex"] = "0"; // 65
    tx["blockTimestamp"] = "1598498652";
    tx["isError"] = "0";

    txns.push_back(tx);

    tx["hash"] = "0x157bb5ce2940078e497b8ffb2dc1af0db6ad46f9e9b133bbd521a73cde27c941";
    tx["from"] = "0x53781e106a2e3378083bdcede1874e5c2a7225f8";
    tx["to"] = "0xd2fbb995bd917d0f6655f41c4006cc58da7603df";
    tx["contract"] = ""; // or "", if none was created
    tx["amount"] = "1000000000000000000"; // 4290000000000000
    tx["gasLimit"] = "8000000";
    tx["gasPrice"] = "1000000000"; // 20000000000
    tx["data"] = ""; // input
    tx["nonce"] = "2"; // 21
    tx["gasUsed"] = "21000"; // 50000
    tx["blockNumber"] = "1195"; // 6139707
    tx["blockHash"] = "0xafa2792ae11ec429d705bc1b8f99c0ddf5f6c17cdab69105fcd19aa453ad3041";
    tx["blockConfirmations"] = "75482"; // 256
    tx["blockTransactionIndex"] = "0"; // 65
    tx["blockTimestamp"] = "1598499275";
    tx["isError"] = "0";

    txns.push_back(tx);
    j["id"] = id;
    j["result"] = txns;
    return j;
}

/**
 * @param contract
 * @param address
 * @param event
 * @param begBlockNumber
 * @param endBlockNumber
 * @param id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": [{
 *     "hash":"0xdf829c5a142f1fccd7d8216c5785ac562ff41e2dcfdf5785ac562ff41e2dcf",
 *     "contract":"0xb60e8dd61c5d32be8058bb8eb970870f07233155", // or "", if none was created
 *     "topics":["0x59ebeb90bc63057b6515673c3ecf9438e5058bca0f92585014eced636878c9a5"]
 *     "data":"0x0000000000000000000000000000000000000000000000000000000000000000",
 *     "gasPrice":"0x4a817c800", // 20000000000
 *     "gasUsed":"0x4dc", // 1244
 *     "logIndex":"0x1", // 1
 *     "blockNumber":"0x1b4", // 436
 *     "blockTransactionIndex":"0x0", // 0
 *     "blockTimestamp":"0x55ba467c",
 *   },{
 *    ...
 *   }]
 * }
 */
nlohmann::json ElaSubWalletCallback::GetLogs(const std::string &contract,
                               const std::string &address,
                               const std::string &event,
                               uint64_t begBlockNumber,
                               uint64_t endBlockNumber,
                                             int id) {
    nlohmann::json j, log, logs = nlohmann::json::array();
    // rpc request
    log["hash"] = "0xdf829c5a142f1fccd7d8216c5785ac562ff41e2dcfdf5785ac562ff41e2dcf";
    log["contract"] = "0xb60e8dd61c5d32be8058bb8eb970870f07233155"; // or "", if none was created
    log["topics"] = nlohmann::json::array({"0x59ebeb90bc63057b6515673c3ecf9438e5058bca0f92585014eced636878c9a5"});
    log["data"] = "0x0000000000000000000000000000000000000000000000000000000000000000";
    log["gasPrice"] = "0x4a817c800"; // 20000000000
    log["gasUsed"] = "0x4dc"; // 1244
    log["logIndex"] = "0x1"; // 1
    log["blockNumber"] = "0x1b4"; // 436
    log["blockTransactionIndex"] = "0x0"; // 0
    log["blockTimestamp"] = "0x55ba467c";
    
    logs.push_back(log);
    
    j["id"] = id;
    j["result"] = logs;
    return j;
}

/**
 * @param id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * [{
 *   "address": "0x407d73d8a49eeb85d32cf465507dd71d507100c1",
 *   "symbol": "ELA",
 *   "name": "elastos",
 *   "description": "desc",
 *   "decimals": 18,
 *   "defaultGasLimit": "0x1388",
 *   "defaultGasPrice": "0x1dfd14000" // 8049999872 Wei
 * },{
 *   ...
 * }]
 */
nlohmann::json ElaSubWalletCallback::GetTokens(int id) {
    nlohmann::json j, token, tokens = nlohmann::json::array();
    j["id"] = id;
    
    token["address"] = "0x407d73d8a49eeb85d32cf465507dd71d507100c1";
    token["symbol"] = "ELA";
    token["name"] = "elastos";
    token["description"] = "desc";
    token["decimals"] = 18;
    token["defaultGasLimit"] = "0x1388";
    token["defaultGasPrice"] = "0x1dfd14000";
    
    tokens.push_back(token);
    
    j["result"] = tokens;
    return j;
}

/**
 * @param id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id":0,
 *   "result": "0x4b7" // 1207
 * }
 */
nlohmann::json ElaSubWalletCallback::GetBlockNumber(int id) {
    nlohmann::json j;
    j["id"] = id;
    j["result"] = "0x4b7";
    return j;
}

/**
 * @param address
 * @param id
 * @return If successful, return below. Otherwise {} or null will be returned to indicate the error.
 * {
 *   "id": 0,
 *   "result": "0x1" // 1
 * }
 */
nlohmann::json ElaSubWalletCallback::GetNonce(const std::string &address, int id) {
    nlohmann::json j;
    j["id"] = id;
    j["result"] = "0x01";
    return j;
}


//@end
