//
//  AppDelegate.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "HNManager.h"
#import "PocketAPI.h"
@interface AppDelegate()

@end

@implementation AppDelegate

- (void)startHNsession
{
    [[HNManager sharedManager] startSession];
}
- (void)setupPocket
{
    [[PocketAPI sharedAPI] setConsumerKey:@"23344-c7d00c8b0846ebd1ecd75032"];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self startHNsession];
    [self setupPocket];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window makeKeyAndVisible];
return YES;
}

#pragma mark - TWTSideMenuViewControllerDelegate
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if([[PocketAPI sharedAPI] handleOpenURL:url]){
        return YES;
    }else{
        // if you handle your own custom url-schemes, do it here
        return NO;
    }
    
}

@end

