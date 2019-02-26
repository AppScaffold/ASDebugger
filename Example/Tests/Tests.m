//
//  ASDebuggerTests.m
//  ASDebuggerTests
//
//  Created by square on 03/09/2016.
//  Copyright (c) 2016 利伽. All rights reserved.
//

@import ASDebugger;
@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];

    [ASDebugger startWithAppKey:@"888" secret:@""];

    NSData *responseBody;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    responseBody = [NSData dataWithContentsOfFile:path];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrackingStatus
{
    XCTAssertTrue([[ASDebugger shared] isTracking]);
}

@end

