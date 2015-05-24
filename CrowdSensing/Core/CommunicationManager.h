//
//  CommunicationManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileServiceException.h"
#import "SOSManager.h"

@class SOSSensor;

@protocol CommunicationManagerDelegate <NSObject>

@optional

- (void) registrationWasSuccessful:(SOSSensor*)sensor;
- (void) registrationFailed:(SOSSensor*)sensor withException:(CSException*)ex;

@end


@interface CommunicationManager : NSObject

+ (CommunicationManager *) sharedInstance;

+ (NSString *) dateToString: (NSDate *) date;
+ (NSDate *) stringToDate: (NSString *) text;
- (NSString*) getDeviceID;

- (void) registerSensor:(SOSSensor *)sensor withDelegate:(id<CommunicationManagerDelegate>)delegate;
- (void) syncronizeDataWithType:(SensorType)type;

@end
