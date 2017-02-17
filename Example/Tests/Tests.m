//
//  ASDebuggerTests.m
//  ASDebuggerTests
//
//  Created by square on 03/09/2016.
//  Copyright (c) 2016 利伽. All rights reserved.
//

#import "ASNetworkRecorder.h"
#import "ASNetworkTransaction.h"

@interface ASNetworkRecorder ()

- (void)handleTransactionUpdatedNotificationToServer:(ASNetworkTransaction *)transaction;

@end

@interface ASNetworkRecorder ()

@property (nonatomic, strong) NSCache *responseCache;

@end

@import XCTest;

@interface Tests : XCTestCase
{
    ASNetworkRecorder *_recorder;
}
@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    
    [ASNetworkRecorder startWithHost:@"http://127.0.0.1:3000/" appKey:@"8888"];
    
    _recorder = [ASNetworkRecorder defaultRecorder];
    _recorder.responseCache = [[NSCache alloc] init];
    
    NSData *responseBody;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    responseBody = [NSData dataWithContentsOfFile:path];
    
    [_recorder.responseCache setObject:responseBody forKey:@"kTestCache" cost:[responseBody length]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTestExpectation *exp = [self expectationWithDescription:@"fetch option"];
    
    ASNetworkTransaction *transaction = [ASNetworkTransaction new];
    transaction.transactionState = ASNetworkTransactionStateFinished;
    transaction.requestID = @"kTestCache";
    [_recorder handleTransactionUpdatedNotificationToServer:transaction];
    
    [exp performSelector:@selector(fulfill) withObject:nil afterDelay:4];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}

@end

