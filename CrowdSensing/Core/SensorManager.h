//
//  SensorManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enumerations.h"
@import CoreMotion;

@interface SensorManager : NSObject

+ (SensorManager *) sharedInstance;

@property (readonly) CMMotionManager *motionManager;
@property (nonatomic) PhonePosition phonePosition;

- (void) startMeasureAccelerationSensors:(bool)acceleration gyroscope:(bool)gyroscope;
- (void) stopMeasure;

@end
