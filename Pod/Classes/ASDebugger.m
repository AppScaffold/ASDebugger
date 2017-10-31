//
//  ASNetworkConfiguration.m
//  Pods
//
//  Created by zhao wei on 11/10/16.
//
//

#import "ASDebugger.h"
#import <objc/message.h>

static NSString * const ASDefaultRemoteRecordHost = @"https://appscaffold.net";
static NSString * const ASDefaultRemoteWebSocketPath = @"https://appscaffold.net/websocket";

@interface ASDebugger () <SRWebSocketDelegate>

@property (nonatomic, strong) NSString *mockPath;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic) NSInteger socketConnectRetryTimes;

@end

@implementation ASDebugger

@synthesize recorderHost = _recorderHost;
@synthesize recorderAppKey = _recorderAppKey;
@synthesize recorderAppSecret = _recorderAppSecret;
@synthesize tracking = _tracking;
@synthesize mocking = _mocking;

+ (instancetype)shared
{
    static ASDebugger *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[[self class] alloc] init];
    });
    return config;
}

+ (instancetype)startWithAppKey:(NSString *)key secret:(NSString *)secret
{
    return [self startWithAppKey:key secret:secret customHost:nil];
}

+ (instancetype)startWithAppKey:(NSString *)key secret:(NSString *)secret customHost:(NSString *)host
{
    return [self initWithAppKey:key secret:secret customHost:host track:YES];
}

+ (instancetype)initWithAppKey:(NSString *)key secret:(NSString *)secret
{
    return [self initWithAppKey:key secret:secret customHost:nil track:NO];
}

+ (instancetype)initWithAppKey:(NSString *)key secret:(NSString *)secret customHost:(NSString *)host track:(BOOL)track
{
    if (!host) {
        host = ASDefaultRemoteRecordHost;
    }
    
    ASDebugger *config = [[self class] shared];
    
    config->_recorderHost = host;
    config->_recorderAppKey = key;
    config->_recorderAppSecret = secret;
    
    [NSURLProtocol registerClass:[ASNetworkIntercept class]];
    
    [self injectURLSessionClass];

    if (track) {
        [config start];
    } else {
        [config stop];
    }
    
    return config;
}

- (void)start
{
    if (_recorderAppKey != nil && _recorderAppSecret != nil) {
        _tracking = true;
        
        [self connectMockServer];
    } else {
#if DEBUG
        NSLog(@"[ASDebugger] error: key or secret is empty! ");
#endif
    }
}

- (void)stop
{
    _tracking = false;
}

- (void)enableMock
{
    _mocking = YES;
    [self connectMockServer];
}

- (void)disableMock
{
    _mocking = NO;
    [self closeMockServer];
}

- (void)enableMockWithPath:(NSString *)path
{
    _mockPath = path;
    [self enableMock];
}

- (void)enableMockWithPath:(NSString *)path mockUrl:(NSString *)url
{
    [self enableMockWithPath:path];
    _mockUrl = url;
}

/** Inject NSURLSession */

/**
  For using other NSURLSession instance. i.e : AFNetworking, SDWebImage
 */
+ (void)injectURLSessionClass {
    SEL originalSelector = @selector(sessionWithConfiguration:delegate:delegateQueue:);
    SEL swizzledSelector = NSSelectorFromString(@"ex_sessionWithConfiguration:delegate:delegateQueue:");
    
    [self replaceImplementationOfKnownSelector:originalSelector onClass:objc_getMetaClass("NSURLSession") withBlock:^NSURLSession*(NSURLSession *slf, NSURLSessionConfiguration *configuration, id <NSURLSessionDelegate> delegate, NSOperationQueue *queue){
        configuration.protocolClasses = @[[ASNetworkIntercept class]];
        return ((id(*)(id, SEL, NSURLSessionConfiguration*, id, NSOperationQueue*))objc_msgSend)(slf, swizzledSelector, configuration, delegate, queue);
    } swizzledSelector:swizzledSelector];
}

+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block swizzledSelector:(SEL)swizzledSelector
{
    // This method is only intended for swizzling methods that are know to exist on the class.
    // Bail if that isn't the case.
    Method originalMethod = class_getClassMethod(class, originalSelector);
    if (!originalMethod) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method newMethod = class_getClassMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, newMethod);
    
//    NSLog(@"%@", [class performSelector:@selector(_methodDescription)]);
}

/**
 MARK: Web Socket
 
 Automatically enable mock environment via WebSocket from mock server settings
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
#if DEBUG
    NSLog(@"ASDebugger: MockServer recevie message %@", message);
#endif
    _socketConnectRetryTimes = 0;
    if ([message isKindOfClass:[NSString class]] && [message hasPrefix:@"m:"]) {
        NSString *originText = message;
        NSRange range = NSMakeRange(2, originText.length - 2);
        NSString *api = [message substringWithRange:range];
        [[ASDebugger shared] enableMockWithPath:api];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
#if DEBUG
    NSLog(@"ASDebugger: MockServer recevie pong!");
#endif
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
#if DEBUG
    NSLog(@"ASDebugger: MockServer did fail connect!");
#endif
    [self connectMockServer];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
#if DEBUG
    NSLog(@"ASDebugger: MockServer is closed!");
#endif
    [self connectMockServer];
}

- (void)connectMockServer {
    if (_socketConnectRetryTimes >= 3) {
#if DEBUG
    NSLog(@"ASDebugger: trying connect to mock server too much!");
#endif
        return;
    }
    
    _socketConnectRetryTimes += 1;
    
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:ASDefaultRemoteWebSocketPath]];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)closeMockServer {
    [self.socket close];
}

@end
