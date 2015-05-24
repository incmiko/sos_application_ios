//
//  LocationManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 12. 16..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BackgroundTaskManager.h"

@interface LocationManager : NSObject

@property (nonatomic) NSTimer *timer;
@property (nonatomic) BackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;

+(id)sharedInstance;

@end
