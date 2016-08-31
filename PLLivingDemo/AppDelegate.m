//
//  AppDelegate.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "AppDelegate.h"
#import "LDLobbyViewController.h"
#import "LDCookies.h"
#import "LDUser.h"
#import "LDLoginViewController.h"
#import "LDLivingConfiguration.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PLStreamingEnv initEnv];
    [[LDLivingConfiguration sharedLivingConfiguration] setupAllConfiguration];
    [[LDCookies sharedCookies] revert];
    
    self.window = ({
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [[LDBasicViewController alloc] init];
        window.backgroundColor = [UIColor whiteColor];
        window.rootViewController.view.frame = self.window.bounds;
        window.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                          UIViewAutoresizingFlexibleHeight;
        window;
    });
    [self.window makeKeyAndVisible];
    [[LDUser sharedUser] loadFromUserDefaults];
    
    UIViewController *viewController;
    if ([[LDUser sharedUser] hasSetUserInfo]) {
        viewController = [[LDLobbyViewController alloc] init];
    } else {
        viewController = [[LDLoginViewController alloc] init];
    }
    [self.window.basicViewController popupViewController:viewController animated:NO completion:nil];
    
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
