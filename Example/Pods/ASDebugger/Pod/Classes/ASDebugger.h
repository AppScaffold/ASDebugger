//
//  ASNetworkConfiguration.h
//  Pods
//
//  Created by zhao wei on 11/10/16.
//
//

#import <Foundation/Foundation.h>
#import "ASNetworkIntercept.h"
#import <SocketRocket/SRWebSocket.h>

@interface ASDebugger : NSObject

@property (nonatomic, strong, readonly) NSString *recorderHost;
@property (nonatomic, strong, readonly) NSString *recorderAppKey;
@property (nonatomic, strong, readonly) NSString *recorderAppSecret;

@property (nonatomic, readonly, getter=isTracking) BOOL tracking;

+ (instancetype)shared;

// Default host is http://appscaffold.net
+ (instancetype)startWithAppKey:(NSString *)key secret:(NSString *)secret;

// Custom host
+ (instancetype)startWithAppKey:(NSString *)key secret:(NSString *)secret customHost:(NSString *)host;

// There is initialized with App key only. will not track request immediately. you could open it manually if you need to launch tracking, calls -start
+ (instancetype)initWithAppKey:(NSString *)key secret:(NSString *)secret;

- (void)start;

- (void)stop;

// Mock

@property (nonatomic, readonly, getter=isMocking)  BOOL mocking;
@property (nonatomic, strong, readonly) NSString *mockPath;
@property (nonatomic, strong) NSString *mockUrl;

// Manually enable mock settings
- (void)enableMock;

- (void)enableMockWithPath:(NSString *)path;

- (void)enableMockWithPath:(NSString *)path mockUrl:(NSString *)url;

- (void)disableMock;

@end

