//
//  SensorManager.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "SensorManager.h"
#import "DataManager.h"

@interface SensorManager ()

- (void) startMeasureAcceleration;
- (void) startMeasureGyroscope;

@end

@implementation SensorManager

@synthesize motionManager,phonePosition;

static SensorManager *sharedInstance;

+ (SensorManager *) sharedInstance {
    
    if (!sharedInstance)
        sharedInstance = [[SensorManager alloc] init];
    
    return sharedInstance;
}

- (CMMotionManager *)motionManager
{
    if (!motionManager) motionManager = [[CMMotionManager alloc] init];
    
    return motionManager;
}

- (id) init{
    
    self = [super init];
    if (self) {
        [self motionManager];
    }
    return self;
}

- (void) startMeasureAccelerationSensors:(bool)acceleration gyroscope:(bool)gyroscope{
    
    if (acceleration)
        [self startMeasureAcceleration];
    
    if (gyroscope)
        [self startMeasureGyroscope];
    
}

- (void) stopMeasure{
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopDeviceMotionUpdates];
}


- (void) startMeasureAcceleration
{
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error){
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           float G = [self getGForceFromX:data.acceleration.x Y:data.acceleration.y Z:data.acceleration.z];
                           [DataManager sharedInstance].actualData.acceleration = G;
                           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCELERATION_CHANGED object:self userInfo:nil];

                       });
    }];
    
}

- (float) getGForceFromX:(float)dataX Y:(float)dataY Z:(float)dataZ{
    float Gforce = fabs(sqrt (pow(dataX,2) + pow(dataY,2) + pow(dataZ,2)) - 1);
    return Gforce;
}

- (void) startMeasureGyroscope{

    if([self.motionManager isGyroAvailable])
    {
        if([self.motionManager isGyroActive] == NO)
        {
            
            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                                    toQueue:[NSOperationQueue mainQueue]
                                                                withHandler:^(CMDeviceMotion *motion, NSError *error)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     
                     
                     if (((motion.gravity.z > -1.35 && motion.gravity.z < -0.65)||(motion.gravity.z < 1.35 && motion.gravity.z >0.65)) && motion.gravity.y > -0.65) {
                         phonePosition = PhonePosition_Lying;
                     }
                     else if (((motion.gravity.y > -1.35 && motion.gravity.y < -0.65)||(motion.gravity.y < 1.35 && motion.gravity.y > 0.65)) && motion.gravity.z > -0.65){
                         phonePosition = PhonePosition_Standing;
                     }
                     else{
                         phonePosition = PhonePosition_NotSet;
                     }

                     [DataManager sharedInstance].actualData.phonePosition = phonePosition;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONEPOSITION_CHANGED object:self userInfo:nil];

                }];
             }];
        }
    }
    else
    {
        TestLog(@"Gyroscope not Available!");
    }
}



@end
