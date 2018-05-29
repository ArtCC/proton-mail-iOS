// Objective-C API for talking to pm Go package.
//   gobind -lang=objc pm
//
// File is generated by gobind. Do not edit.

#ifndef __Pm_H__
#define __Pm_H__

@import Foundation;
#include "Universe.objc.h"


@class PmAddress;
@class PmDecryptSignedVerify;
@class PmEncryptedSigned;
@class PmEncryptedSplit;
@class PmKey;
@class PmOpenPGP;
@class PmSessionSplit;

@interface PmAddress : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
@end

@interface PmDecryptSignedVerify : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)plaintext;
- (void)setPlaintext:(NSString*)v;
- (long)verify;
- (void)setVerify:(long)v;
- (NSString*)message;
- (void)setMessage:(NSString*)v;
@end

@interface PmEncryptedSigned : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)encrypted;
- (void)setEncrypted:(NSString*)v;
- (NSString*)signature;
- (void)setSignature:(NSString*)v;
@end

@interface PmEncryptedSplit : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSData*)dataPacket;
- (void)setDataPacket:(NSData*)v;
- (NSData*)keyPacket;
- (void)setKeyPacket:(NSData*)v;
- (NSString*)algo;
- (void)setAlgo:(NSString*)v;
@end

@interface PmKey : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)keyID;
- (void)setKeyID:(NSString*)v;
- (NSString*)publicKey;
- (void)setPublicKey:(NSString*)v;
- (NSString*)privateKey;
- (void)setPrivateKey:(NSString*)v;
- (NSString*)fingerPrint;
- (void)setFingerPrint:(NSString*)v;
@end

@interface PmOpenPGP : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSData*)decryptAttachment:(NSData*)keyPacket dataPacket:(NSData*)dataPacket privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase error:(NSError**)error;
- (NSData*)decryptAttachmentBinKey:(NSData*)keyPacket dataPacket:(NSData*)dataPacket privateKeys:(NSData*)privateKeys passphrase:(NSString*)passphrase error:(NSError**)error;
- (NSData*)decryptAttachmentWithPassword:(NSData*)keyPacket dataPacket:(NSData*)dataPacket password:(NSString*)password error:(NSError**)error;
- (NSString*)decryptMessage:(NSString*)encryptedText privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase error:(NSError**)error;
- (NSString*)decryptMessageBinKey:(NSString*)encryptedText privateKey:(NSData*)privateKey passphrase:(NSString*)passphrase error:(NSError**)error;
- (PmDecryptSignedVerify*)decryptMessageVerify:(NSString*)encryptedText veriferKey:(NSString*)veriferKey privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase verifyTime:(int64_t)verifyTime error:(NSError**)error;
- (PmDecryptSignedVerify*)decryptMessageVerifyBinKey:(NSString*)encryptedText veriferKey:(NSData*)veriferKey privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase verifyTime:(int64_t)verifyTime error:(NSError**)error;
- (PmDecryptSignedVerify*)decryptMessageVerifyBinKeyPrivbinkeys:(NSString*)encryptedText veriferKey:(NSData*)veriferKey privateKeys:(NSData*)privateKeys passphrase:(NSString*)passphrase verifyTime:(int64_t)verifyTime error:(NSError**)error;
- (PmDecryptSignedVerify*)decryptMessageVerifyPrivbinkeys:(NSString*)encryptedText veriferKey:(NSString*)veriferKey privateKeys:(NSData*)privateKeys passphrase:(NSString*)passphrase verifyTime:(int64_t)verifyTime error:(NSError**)error;
- (NSString*)decryptMessageWithPassword:(NSString*)encrypted password:(NSString*)password error:(NSError**)error;
- (PmEncryptedSplit*)encryptAttachment:(NSData*)plainData fileName:(NSString*)fileName publicKey:(NSString*)publicKey error:(NSError**)error;
- (PmEncryptedSplit*)encryptAttachmentBinKey:(NSData*)plainData fileName:(NSString*)fileName publicKey:(NSData*)publicKey error:(NSError**)error;
- (NSString*)encryptAttachmentWithPassword:(NSData*)plainData password:(NSString*)password error:(NSError**)error;
- (NSString*)encryptMessage:(NSString*)plainText publicKey:(NSString*)publicKey privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase trim:(BOOL)trim error:(NSError**)error;
- (NSString*)encryptMessageBinKey:(NSString*)plainText publicKey:(NSData*)publicKey privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase trim:(BOOL)trim error:(NSError**)error;
- (NSString*)encryptMessageWithPassword:(NSString*)plainText password:(NSString*)password error:(NSError**)error;
- (NSString*)generateKey:(NSString*)userName domain:(NSString*)domain passphrase:(NSString*)passphrase keyType:(NSString*)keyType bits:(long)bits error:(NSError**)error;
- (int64_t)getTime;
- (BOOL)isKeyExpired:(NSString*)publicKey ret0_:(BOOL*)ret0_ error:(NSError**)error;
- (BOOL)isKeyExpiredBin:(NSData*)publicKey ret0_:(BOOL*)ret0_ error:(NSError**)error;
- (NSString*)signBinDetached:(NSData*)plainData privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase error:(NSError**)error;
- (NSString*)signBinDetachedBinKey:(NSData*)plainData privateKey:(NSData*)privateKey passphrase:(NSString*)passphrase error:(NSError**)error;
- (NSString*)signTextDetached:(NSString*)plainText privateKey:(NSString*)privateKey passphrase:(NSString*)passphrase trim:(BOOL)trim error:(NSError**)error;
- (NSString*)signTextDetachedBinKey:(NSString*)plainText privateKey:(NSData*)privateKey passphrase:(NSString*)passphrase trim:(BOOL)trim error:(NSError**)error;
- (NSString*)updatePrivateKeyPassphrase:(NSString*)privateKey oldPassphrase:(NSString*)oldPassphrase newPassphrase:(NSString*)newPassphrase error:(NSError**)error;
- (void)updateTime:(int64_t)newTime;
- (BOOL)verifyBinSignDetached:(NSString*)signature plainData:(NSData*)plainData publicKey:(NSString*)publicKey verifyTime:(int64_t)verifyTime ret0_:(BOOL*)ret0_ error:(NSError**)error;
- (BOOL)verifyBinSignDetachedBinKey:(NSString*)signature plainData:(NSData*)plainData publicKey:(NSData*)publicKey verifyTime:(int64_t)verifyTime ret0_:(BOOL*)ret0_ error:(NSError**)error;
- (BOOL)verifyTextSignDetached:(NSString*)signature plainText:(NSString*)plainText publicKey:(NSString*)publicKey verifyTime:(int64_t)verifyTime ret0_:(BOOL*)ret0_ error:(NSError**)error;
- (BOOL)verifyTextSignDetachedBinKey:(NSString*)signature plainText:(NSString*)plainText publicKey:(NSData*)publicKey verifyTime:(int64_t)verifyTime ret0_:(BOOL*)ret0_ error:(NSError**)error;
@end

@interface PmSessionSplit : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSData*)session;
- (void)setSession:(NSData*)v;
- (NSString*)algo;
- (void)setAlgo:(NSString*)v;
@end

FOUNDATION_EXPORT NSString* PmArmorKey(NSData* input, NSError** error);

FOUNDATION_EXPORT NSString* PmArmorWithType(NSData* input, NSString* armorType, NSError** error);

FOUNDATION_EXPORT NSString* PmCheckKey(NSString* pubKey, NSError** error);

FOUNDATION_EXPORT BOOL PmCheckPassphrase(NSString* privateKey, NSString* passphrase);

FOUNDATION_EXPORT NSString* PmGetFingerprint(NSString* publicKey, NSError** error);

FOUNDATION_EXPORT NSString* PmGetFingerprintBinKey(NSData* publicKey, NSError** error);

FOUNDATION_EXPORT PmSessionSplit* PmGetSessionFromKeyPacket(NSData* keyPackage, NSString* privateKey, NSString* passphrase, NSError** error);

FOUNDATION_EXPORT PmSessionSplit* PmGetSessionFromKeyPacketBinkeys(NSData* keyPackage, NSData* privateKey, NSString* passphrase, NSError** error);

FOUNDATION_EXPORT PmSessionSplit* PmGetSessionFromSymmetricPacket(NSData* keyPackage, NSString* password, NSError** error);

FOUNDATION_EXPORT NSData* PmKeyPacketWithPublicKey(PmSessionSplit* sessionSplit, NSString* publicKey, NSError** error);

FOUNDATION_EXPORT NSData* PmKeyPacketWithPublicKeyBin(PmSessionSplit* sessionSplit, NSData* publicKey, NSError** error);

FOUNDATION_EXPORT NSString* PmPublicKey(NSString* privateKey, NSError** error);

FOUNDATION_EXPORT NSData* PmRandomToken(NSError** error);

FOUNDATION_EXPORT NSData* PmRandomTokenWith(long size, NSError** error);

FOUNDATION_EXPORT NSString* PmReadClearSignedMessage(NSString* signedMessage, NSError** error);

FOUNDATION_EXPORT PmEncryptedSplit* PmSeparateKeyAndData(NSString* encrypted, NSError** error);

FOUNDATION_EXPORT NSData* PmSymmetricKeyPacketWithPassword(PmSessionSplit* sessionSplit, NSString* password, NSError** error);

FOUNDATION_EXPORT NSData* PmUnArmor(NSString* input, NSError** error);

FOUNDATION_EXPORT NSString* PmVersion(void);

#endif
