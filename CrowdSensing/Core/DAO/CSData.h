//
//  CSData.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPSPosition.h"
#import "Enumerations.h"

@interface CSData : NSObject

@property (nonatomic) GPSPosition* gpsPosition;
@property (nonatomic) PhonePosition phonePosition;
@property (nonatomic) float acceleration;
@property (nonatomic) float magneticHeading;

- (NSString*) getStringValueOfPhonePosition;
- (int) getIntValueOfPhonePosition;

@end
