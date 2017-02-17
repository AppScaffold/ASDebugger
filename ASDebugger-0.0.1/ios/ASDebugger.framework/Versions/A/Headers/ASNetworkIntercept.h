//
//  ASNetworkIntercept.h
//  ASDebugger
//
//  Created by square on 11/3/16.
//
//

#import <Foundation/Foundation.h>
#import "ASDebugger.h"

@interface ASNetworkIntercept : NSURLProtocol

@end

@interface RecordInfo : NSObject

@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSString *requestMethod;
@property (nonatomic, strong) NSData *requestBody;
@property (nonatomic, strong) NSData *responseBody;
@property (nonatomic, strong) NSString *responseMIMEType;
@property (nonatomic, assign) long long responseSize;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *statusCode;

- (void)saveToRemote;

@end

typedef NS_ENUM(NSInteger, ASNetworkTransactionMimeType) {
    ASNetworkTransactionMimeTypeJSON,
    ASNetworkTransactionMimeTypeImage,
    ASNetworkTransactionMimeTypePlain,
    ASNetworkTransactionMimeTypeHTML,
    ASNetworkTransactionMimeTypeXPlist,
    ASNetworkTransactionMimeTypeBinary,
    ASNetworkTransactionMimeTypeJavascript,
    ASNetworkTransactionMimeTypeXML,
    ASNetworkTransactionMimeTypeAudio,
    ASNetworkTransactionMimeTypeVideo,
    ASNetworkTransactionMimeTypeText
};

@interface ASNetworkUtils : NSObject

+ (ASNetworkTransactionMimeType)mimeTypeWithString:(NSString *)mimeType;

+ (BOOL)isValidJSONData:(NSData *)data;

+ (BOOL)isJSONPData:(NSData *)data;

+ (NSString *)prettyJSONStringFromData:(NSData *)data;

+ (NSString *)prettyJSONStringFromJSONPData:(NSData *)data;

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)duration;

@end
