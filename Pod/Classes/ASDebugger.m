//
//  ASNetworkConfiguration.m
//  Pods
//
//  Created by zhao wei on 11/10/16.
//
//

#import "ASDebugger.h"
#import <objc/message.h>

@interface ASDebugger ()

@property (nonatomic, strong) NSString *mockPath;

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
    return [self startWithAppKey:key secret:secret customHost:host inject:YES];
}

+ (instancetype)initWithAppKey:(NSString *)key secret:(NSString *)secret
{
    return [self startWithAppKey:key secret:secret customHost:nil inject:NO];
}

+ (instancetype)startWithAppKey:(NSString *)key secret:(NSString *)secret customHost:(NSString *)host inject:(BOOL)inject
{
    if (!host) {
        host = @"http://appscaffold.net";
    }
    
    ASDebugger *config = [[self class] shared];
    
    config->_recorderHost = host;
    config->_recorderAppKey = key;
    config->_recorderAppSecret = secret;
    config->_tracking = inject;
    
    [NSURLProtocol registerClass:[ASNetworkIntercept class]];
    
    [self injectURLSessionClass];
    
    return config;
}

- (void)start
{
    _tracking = true;
}

- (void)stop
{
    _tracking = false;
}

- (void)enableMock
{
    _mocking = YES;
}

- (void)disableMock
{
    _mocking = NO;
}

- (void)enableMockWithPath:(NSString *)path
{
    _mockPath = path;
    _mocking = YES;
}

- (void)enableMockWithPath:(NSString *)path mockUrl:(NSString *)url
{
    _mockPath = path;
    _mocking = YES;
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

@end
