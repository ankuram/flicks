//
//  AppDelegate.m
//  flicks
//
//  Created by Ankur Motreja on 9/12/16.
//  Copyright © 2016 Ankur Motreja. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *nowPlayingNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MoviesNavigationController"];
    MoviesViewController *nowPlayingController = (MoviesViewController *)[nowPlayingNavigationController topViewController];
    nowPlayingController.title = @"Now Playing";
    nowPlayingController.endpoint = @"now_playing";
    
    UINavigationController *topRatedNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MoviesNavigationController"];
    MoviesViewController *topRatedViewController = (MoviesViewController *)[topRatedNavigationController topViewController];
    topRatedViewController.title = @"Top Rated";
    topRatedViewController.endpoint = @"top_rated";
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[nowPlayingNavigationController, topRatedNavigationController];

    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *nowPlayingTabBarItem = [tabBar.items objectAtIndex:0];
    nowPlayingTabBarItem.title = @"Now Playing";
    nowPlayingTabBarItem.image = [UIImage imageNamed:@"video-32.png"];
    
    UITabBarItem *topRatedTabBarItem = [tabBar.items objectAtIndex:1];
    topRatedTabBarItem.title = @"Top Rated";
    topRatedTabBarItem.image = [UIImage imageNamed:@"star-32.png"];

    self.window.rootViewController = tabBarController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
