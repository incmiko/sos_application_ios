//
//  SOSManager.h
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 09..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPSPosition.h"

typedef enum {
    SensorType_Magnetometer,
    SensorType_Accelerometer,
    SensorType_GYRO
} SensorType;

@class SOSSensor;

@interface SOSManager : NSObject

+ (SOSManager *) sharedInstance;

- (void) registerSensorForType:(SensorType)type;
- (void) registerUnregisteredSensors;

- (void) loadSOSSensors;
- (void) loadSOSSensorForType:(SensorType)type;

- (bool) detectSensorIsRegistered:(SensorType)type;
- (bool) allSensorsRegistered;
- (SOSSensor*) findSOSSensorForType:(SensorType)type;
- (NSString*) getKeyForType:(SensorType)type;

- (void) updateSensorsPosition:(GPSPosition*)position;

@end
