//
//  ASNetworkIntercept.m
//  ASDebugger
//
//  Created by square on 11/3/16.
//
//

#import "ASNetworkIntercept.h"

static NSString * const ASInterceptURLHeader = @"X-ASIntercept";

@interface ASNetworkIntercept ()

@property (nonatomic, readwrite, strong) NSURLSessionDataTask *sessionTask;

@property (nonatomic, strong) NSDate *startTime;

@end

@implementation ASNetworkIntercept

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![[ASDebugger shared] isTracking]) {
        return NO;
    }
        
    // Some request are Socket connection. the URL might be nil
    if (!request.URL) {
        return NO;
    }
    
    if ([request valueForHTTPHeaderField:ASInterceptURLHeader] != nil) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(nullable NSCachedURLResponse *)cachedResponse client:(nullable id <NSURLProtocolClient>)client
{
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (void)startLoading
{
    [self buildSessionTask];
}

- (void)stopLoading
{
    [self.sessionTask cancel];
}

- (BOOL)canMockWithUrl:(NSURL *)url
{
    if ([[ASDebugger shared] isMocking]) {
        if ([[ASDebugger shared] mockPath]) {
            if ([url.relativePath isEqualToString:[NSString stringWithFormat:@"/%@", [[ASDebugger shared] mockPath]]]) {
                return YES;
            }
        } else {
            return YES;
        }
    }
    return NO;
}

- (NSURL *)mockUrl:(NSURL *)url
{
    if ([ASDebugger shared].mockUrl) {
        return [NSURL URLWithString:[ASDebugger shared].mockUrl];
    } else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/%@%@?%@", [ASDebugger shared].recorderHost, [ASDebugger shared].recorderAppKey, url.relativePath, url.query]];
    }
}

- (void)buildSessionTask
{
    NSMutableURLRequest *connectionRequest = [[self request] mutableCopy];
    [connectionRequest addValue:@"" forHTTPHeaderField:ASInterceptURLHeader];
    
    if ([self canMockWithUrl:connectionRequest.URL]) {
        connectionRequest.URL = [self mockUrl:connectionRequest.URL];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];

    __weak typeof(self) weakSelf = self;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.startTime = [NSDate date];
    self.sessionTask =
    [session dataTaskWithRequest:connectionRequest
               completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         
         __weak typeof(self) weakSelf = self;
         
         [weakSelf record:weakSelf.request startTime:weakSelf.startTime data:data response:response];
         
         if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
             NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
             
             [weakSelf.client URLProtocol:weakSelf didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
             // the Cache Data could be using here .  `self.cachedData`
             [weakSelf.client URLProtocol:weakSelf didLoadData:data];
             [weakSelf.client URLProtocolDidFinishLoading:weakSelf];
             
             if (statusCode > 300) {
#if DEBUG
//                 NSLog(@"[ASDebugger] error: push to remote failed , network statusCode: %@",@(statusCode));
#endif
             }
         }
         if (error) {
#if DEBUG
//             NSLog(@"[ASDebugger] error: \n debugger error:%@", error);
#endif
         }

         dispatch_semaphore_signal(semaphore);
     }];
    
    [self.sessionTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)record:(NSURLRequest *)request startTime:(NSDate *)startTime data:(NSData *)data response:(NSURLResponse *)response {
    RecordInfo *info = [RecordInfo new];
    info.requestId = [[NSUUID UUID] UUIDString];
    
    /**
     http://stackoverflow.com/questions/9301611/using-a-custom-nsurlprotocol-with-uiwebview-and-post-requests
     https://bugs.webkit.org/show_bug.cgi?id=137299
     
     unfortunately when you send POST requests (with a body) using NSURLSession, by the time the request arrives to stubs, the HTTPBody of the NSURLRequest can't be accessed anymore. This is a known Apple bug.
     
     Therefore, you cannot directly test the request.HTTPBody
     */
    info.requestBody = request.HTTPBody;
    
    info.requestMethod = request.HTTPMethod;
    info.requestUrl = request.URL.absoluteString;
    info.responseBody = data;
    info.responseMIMEType = response.MIMEType;
    info.responseSize = response.expectedContentLength;
    info.startTime = startTime;
    info.endTime = [NSDate date];
    info.statusCode = [self statusCodeStringFromURLResponse:response];
    
    [info saveToRemote];
}

- (NSDate *)dateWithResponse:(NSURLResponse *)response
{
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *date = [httpResponse.allHeaderFields objectForKey:@"date"];
        NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
        startTimeFormatter.dateFormat =  @"E, d LLL yyyy HH:mm:ss Z";
        
        return [startTimeFormatter dateFromString:date];
    }
    
    return nil;
}

- (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response
{
    NSString *httpResponseString = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *statusCodeDescription = nil;
        
        if (httpResponse.statusCode == 200) {
            // Prefer OK to the default "no error"
            statusCodeDescription = @"OK";
        } else {
            statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        }
        httpResponseString = [NSString stringWithFormat:@"%ld %@", (long)httpResponse.statusCode, statusCodeDescription];
    }
    return httpResponseString;
}

@end


@implementation RecordInfo

- (NSDictionary *)dict {
    NSString *request_body = self.requestBody ? [ASNetworkUtils prettyJSONStringFromData:self.requestBody] : nil;
    NSString *response_body = [[NSString alloc] initWithData:self.responseBody encoding:NSUTF8StringEncoding];;
    
    if ([ASNetworkUtils mimeTypeWithString:self.responseMIMEType] == ASNetworkTransactionMimeTypeJSON ||
        [ASNetworkUtils mimeTypeWithString:self.responseMIMEType] == ASNetworkTransactionMimeTypeJavascript) {
        if ([ASNetworkUtils isValidJSONData:self.responseBody]) {
            response_body = [ASNetworkUtils prettyJSONStringFromData:self.responseBody];
        } else if ([ASNetworkUtils isJSONPData:self.responseBody]) {
            response_body = [ASNetworkUtils prettyJSONStringFromJSONPData:self.responseBody];
        }
    }
    
    NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (self.requestId) [paramDic setObject:self.requestId forKey:@"request_id"];
    if (request_body) [paramDic setObject:request_body forKey:@"request_body"];
    if (self.requestMethod) [paramDic setObject:self.requestMethod forKey:@"request_method"];
    if (self.requestUrl) [paramDic setObject:self.requestUrl forKey:@"request_url"];
    if (response_body) [paramDic setObject:response_body forKey:@"response_body"];
    if (self.startTime) [paramDic setObject:[startTimeFormatter stringFromDate:self.startTime] forKey:@"start_time"];
    if (self.endTime) [paramDic setObject:[startTimeFormatter stringFromDate:self.endTime] forKey:@"end_time"];
    if (self.startTime) [paramDic setObject:[NSString stringWithFormat:@"%f", [self.startTime timeIntervalSince1970]] forKey:@"unix_start_time"];
    if (self.startTime && self.endTime) [paramDic setObject:[ASNetworkUtils stringFromTimeInterval:-[self.startTime timeIntervalSinceDate:self.endTime]] forKey:@"total_duration"];
    if (self.statusCode) [paramDic setObject:self.statusCode forKey:@"status_code"];
    if (self.responseMIMEType) [paramDic setObject:self.responseMIMEType forKey:@"mime_type"];
    if (self.responseSize) [paramDic setObject:@(self.responseSize) forKey:@"response_size"];
    
    return paramDic;
}

- (NSString *)serverFetchAPI
{
    return [NSString stringWithFormat:@"%@/network_fetchers", [ASDebugger shared].recorderHost];
}

- (void)saveToRemote{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serverFetchAPI]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30.0];
    [request addValue:@"" forHTTPHeaderField:ASInterceptURLHeader];
    
    NSString *bundleIdentifierKey = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"network_fetcher":self.dict,
                                                                 @"app_key":[ASDebugger shared].recorderAppKey,
                                                                 @"app_secret":[ASDebugger shared].recorderAppSecret,
                                                                 @"bundle_id":bundleIdentifierKey}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task =
    [session dataTaskWithRequest:request
               completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
             NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
             if (statusCode > 300) {
#if DEBUG
                 NSLog(@"[ASDebugger] error: \n push to server failed , network statusCode: %@ \n",@(statusCode));
#endif
             }
         }
         if (error) {
#if DEBUG
             NSLog(@"[ASDebugger] error: \n ====== \n %@ \n ====== \n", error);
#endif
         }
     }];
    
    [task resume];
}

@end

@implementation ASNetworkUtils

+ (ASNetworkTransactionMimeType)mimeTypeWithString:(NSString *)mimeType
{
    if ([mimeType hasPrefix:@"image/"]) {
        return ASNetworkTransactionMimeTypeImage;
        // responseBody is image data
    } else if ([mimeType isEqual:@"application/json"]) {
        return ASNetworkTransactionMimeTypeJSON;
    } else if ([mimeType isEqual:@"text/plain"]){
        return ASNetworkTransactionMimeTypePlain;
    } else if ([mimeType isEqual:@"text/html"]) {
        return ASNetworkTransactionMimeTypeHTML;
    } else if ([mimeType isEqual:@"application/x-plist"]) {
        return ASNetworkTransactionMimeTypeXPlist;
    } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
        return ASNetworkTransactionMimeTypeBinary;
    } else if ([mimeType rangeOfString:@"javascript"].length > 0) {
        return ASNetworkTransactionMimeTypeJavascript;
    } else if ([mimeType rangeOfString:@"xml"].length > 0) {
        return ASNetworkTransactionMimeTypeXML;
    } else if ([mimeType hasPrefix:@"audio"]) {
        return ASNetworkTransactionMimeTypeAudio;
    } else if ([mimeType hasPrefix:@"video"]) {
        return ASNetworkTransactionMimeTypeVideo;
    } else if ([mimeType hasPrefix:@"text"]) {
        return ASNetworkTransactionMimeTypeText;
    }
    return ASNetworkTransactionMimeTypeText;
}

+ (BOOL)isValidJSONData:(NSData *)data
{
    if (!data) {
        return NO;
    }
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] ? YES : NO;
}

+ (BOOL)isJSONPData:(NSData *)data
{
    if (!data) {
        return NO;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [jsonString rangeOfString:@"("];
    if (range.location == NSNotFound) {
        return NO;
    }
    NSRange bRange = [jsonString rangeOfString:@")" options:NSBackwardsSearch];
    if (bRange.location == NSNotFound || bRange.location != jsonString.length - 1) {
        return NO;
    }
    
    range.location++;
    range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
    jsonString = [jsonString substringWithRange:range];
    if (jsonString.length) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)prettyJSONStringFromData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        // NSJSONSerialization escapes forward slashes. We want pretty json, so run through and unescape the slashes.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    
    return prettyString;
}

+ (NSString *)prettyJSONStringFromJSONPData:(NSData *)data
{
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [jsonString rangeOfString:@"("];
    if (range.location == NSNotFound) {
        return nil;
    }
    range.location++;
    range.length = [jsonString length] - range.location - 1;
    jsonString = [jsonString substringWithRange:range];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self prettyJSONStringFromData:jsonData];
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)duration
{
    NSString *string = @"0s";
    if (duration > 0.0) {
        if (duration < 1.0) {
            string = [NSString stringWithFormat:@"%dms", (int)(duration * 1000)];
        } else if (duration < 10.0) {
            string = [NSString stringWithFormat:@"%.2fs", duration];
        } else {
            string = [NSString stringWithFormat:@"%.1fs", duration];
        }
    }
    return string;
}

@end
