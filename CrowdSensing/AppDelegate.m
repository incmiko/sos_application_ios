//
//  AppDelegate.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DataManager.h"
#import "PushNotification.h"
#import "CommunicationManager.h"
#import "UpdatePushTokenRequest.h"


@interface AppDelegate ()

@property (nonatomic,retain) NSString* appStartFromNotiResult;
@property (nonatomic, retain) PushNotification* startPushNotification;

@end

static NSString *pushToken = nil;
static ApplicationStatusWhenPushRecieved appStatusWhenPushReceived;

@implementation AppDelegate

@synthesize appStartFromNotiResult,startPushNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil){
        appStatusWhenPushReceived = ApplicationStatusWhenPushRecieved_NotRunningOrActuallyStarting;
        appStartFromNotiResult = [[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"data"]copy];
        
        startPushNotification = [[PushNotification alloc]init];
        [startPushNotification parseNotificationFromString:appStartFromNotiResult];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.navCtrlr = [[UINavigationController alloc]initWithRootViewController:[MainViewController sharedInstance]];
    [self.navCtrlr setNavigationBarHidden:YES animated:NO];
    [self.window setRootViewController:self.navCtrlr];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - push message handling

//ios 8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        NSLog(@"declineAction");
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        NSLog(@"answerAction");
    }
}


-(void) application: (UIApplication *) app didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) _deviceToken {
    
    pushToken = [NSString stringWithFormat:@"%@",_deviceToken];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    pushToken = [[pushToken stringByReplacingOccurrencesOfString:@" " withString:@""] copy];
    
    if (!pushToken || [pushToken length] == 0) {
        
        NSLog(@"+++ Push token error: token is nil or has 0 length");
        return;
    }
    
    NSLog(@"Token has been successfull registered: %@", pushToken);
    
    //    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Pushtoken" message:pushToken delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //    [alert show];
}


-(void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"+++ Push token error: %@", [err localizedDescription]);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    appStartFromNotiResult = [[userInfo objectForKey:@"data"]copy];
    startPushNotification = [[PushNotification alloc]init];
    [startPushNotification parseNotificationFromString:appStartFromNotiResult];
    
    if ( application.applicationState == UIApplicationStateInactive)
    {
        //opened from a push notification when the app was on background
        if (appStartFromNotiResult){
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            
            if (startPushNotification) {
                
            }
        }
    }
    else if(application.applicationState == UIApplicationStateActive)
    {
        // a push notification when the app is running. So that you can display an alert and push in any view
        
    }
}

@end
