//
//  HWMDIDManager.h
//  elastos wallet
//
//  Created by  on 2020/2/18.
//

#import <Foundation/Foundation.h>
#import "MyUtil.h"
#include "ela_did.h"
#include "HDkey.h"
#include "crypto.h"
#import "HWMDIDInfoModel.h"
NS_ASSUME_NONNULL_BEGIN



@interface HWMDIDManager : NSObject{
    
//    NSString *rootPath;
}
+(instancetype)shareDIDManager;
@property(copy,nonatomic)NSString *passWord;
@property(copy,nonatomic)NSString *DIDString;
@property(copy,nonatomic)NSString *TheMnemonicWordString;
@property(copy,nonatomic)NSString *privatekeyString;
@property(copy,nonatomic)NSString *mastWalletID;

-(void)copyDirToSharedDir;
-(BOOL)saveDir;
-(NSString*)hasDIDWithPWD:(NSString *)passWord withDIDString:(NSString*)DIDString
WithPrivatekeyString:(NSString*)privatekeyString
         WithmastWalletID:(NSString*)mastWalletID needCreatDIDString:(BOOL)need;
-(NSDictionary*)getDIDInfo;
-(BOOL)updateInfoWithInfo:(HWMDIDInfoModel*)model;
-(id)jwtDecodeWithJwtStringInfo:(NSString *)jwtStr;
-(NSString*)PKWith:(const char*)pk58;
-(NSString*)DIDSignatureWithString:(NSString*)sigString;
-(BOOL)saveDIDCredentialWithDIDModel:(HWMDIDInfoModel*)model;
-(HWMDIDInfoModel*)readDIDCredential;
-(bool)CheckDIDwhetherExpiredWithDIDString:(NSString*)didString WithmastWalletID:(NSString*)walletID;
-(id)CRInfoDecodeWithJwtStringInfo:(NSString *)jwtStr;
-(NSString*)generateDIDCredentialString;
-(BOOL)GenerateLocalCredentialsWithFielNameWithFielName:(NSString*)FielName;
-(NSArray*)shareJWTWithmastWalletID:(NSString*)walletID withFileName:(NSString*)fileName needDlea:(void(^)(BOOL de))needDleFile;
-(BOOL)CertificateUpdateWithWalletID:(NSString*)walletID WithFileName:(NSString*)fileName;
-(BOOL)HasBeenOnTheChain;
-(NSString*)adviceTheSignatureWithPWD:(NSString*)pwdString withDigestChar:(char*)DigestChar;
-(NSString*)proposalTheSignatureWithPWD:(NSString*)pwdString withDigestChar:(char*)DigestChar;
-(BOOL)qrTimeWithString:(NSString*)jwtStr;
-(BOOL)AuthenticationWithString:(NSString*)jwtStr;
-(BOOL)ComparedWithThePublicKeyWithmastWalletID:(NSString*)walletID withStringInfo:(NSString *)jwtStr;
-(BOOL)adviceComparedWithThePublicKeyWithmastWalletID:(NSString*)walletID withStringInfo:(NSString *)jwtStr;
-(BOOL)comparedWithTheDIDWithmastWalletID:(NSString*)walletID withStringInfo:(NSString *)jwtStr;
-(BOOL)voteforProposalQrCodeTypeWithString:(NSString*)jwtStr;
@end

NS_ASSUME_NONNULL_END
