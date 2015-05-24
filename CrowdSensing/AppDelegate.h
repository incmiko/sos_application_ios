//
//  AppDelegate.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) MainViewController* mainViewController;
@property (nonatomic, retain) UINavigationController *navCtrlr;



@end

