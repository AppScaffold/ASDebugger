//
//  ASDAppDelegate.m
//  ASDebugger
//
//  Created by square on 03/09/2016.
//  Copyright (c) 2016 利伽. All rights reserved.
//

#import "ASDAppDelegate.h"
#import "ASDViewController.h"
#import "ASDebugger.h"

@implementation ASDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ASDViewController *vc = [ASDViewController new];
    [ASDebugger startWithAppKey:@"d72c151e3a0748fc4d5f" secret:@"670b2454-d5e5-4fc9-8c12-4a6e62049f39"];
    
//    [[ASDebugger shared] enableMock];
//    [[ASDebugger shared] enableMockWithPath:@"user/profile"];
//    [[ASDebugger shared] enableMockWithPath:@"user/profile" mockUrl:@"http://www.google.com/user/profile"];
//    [[ASDebugger shared] stop];
    
//    [[ASDebugger shared] start];
//    [[ASDebugger shared] disableMock];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
