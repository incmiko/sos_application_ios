//
//  BackgroundTaskManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 12. 16..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;

@end
