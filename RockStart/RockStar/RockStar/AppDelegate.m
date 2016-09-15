//
//  AppDelegate.m
//  RockStar
//
//  Created by Patrice Roux on 15/09/2016.
//  Copyright © 2016 Trimech Sedki. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    /////****INIT PLIST DATA*///
    [PlistManager sharedInstance].contactsDictionnary = [[PlistManager sharedInstance] loadContatcsFromCache];
    if (![PlistManager sharedInstance].contactsDictionnary) {
        [PlistManager sharedInstance].contactsDictionnary = [NSMutableDictionary dictionary];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
                ///*** Save Plist To Cache ***/////
    [[PlistManager sharedInstance] saveToCache];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /////****INIT PLIST DATA*///
    [PlistManager sharedInstance].contactsDictionnary = [[PlistManager sharedInstance] loadContatcsFromCache];
    if ([PlistManager sharedInstance].contactsDictionnary) {
        [PlistManager sharedInstance].contactsDictionnary = [NSMutableDictionary dictionary];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    ///*** Save Plist To Cache ***/////

    [[PlistManager sharedInstance] saveToCache];
}

@end
