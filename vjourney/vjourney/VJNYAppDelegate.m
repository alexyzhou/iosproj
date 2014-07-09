//
//  VJNYAppDelegate.m
//  vjourney
//
//  Created by alex on 14-4-24.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYAppDelegate.h"
#import "VJNYUtilities.h"
#import "VJDMModel.h"
#import <ShareSDK/ShareSDK.h>

@implementation VJNYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[VJNYUtilities initTestParameters];
    [ShareSDK registerApp:@"244c039ef6f6"];
    
    [ShareSDK connectSinaWeiboWithAppKey:@"155618031"
                               appSecret:@"b0e1249e98acd5f640d2c6c652023be8"
                             redirectUri:@"http://localhost.vjourney.com/success"];
    
    [ShareSDK connectFacebookWithAppKey:@"747628921926240" appSecret:@"23189d1ba02c0f743f95add68eb3f24a"];
    
    //[[VJDMModel sharedInstance] clearDatabase];
    
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
