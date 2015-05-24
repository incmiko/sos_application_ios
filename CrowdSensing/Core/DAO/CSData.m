//
//  CSData.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "CSData.h"

@implementation CSData

@synthesize gpsPosition,acceleration,phonePosition;

- (id) init{
    
    self = [super init];
    if (self) {
        gpsPosition = [[GPSPosition alloc]init];
    }
    return self;
}

- (NSString*) getStringValueOfPhonePosition{
    
    NSString* value = nil;
    switch (phonePosition) {
        case PhonePosition_NotSet:
            value = @"Unknown";
            break;
        case PhonePosition_Lying:
            value = @"Lying";
            break;
        case PhonePosition_Standing:
            value = @"Standing";
            break;
        default:
            break;
    }
    return value;
}

- (int) getIntValueOfPhonePosition{
    
    int value;
    switch (phonePosition) {
        case PhonePosition_NotSet:
            value = -1;
            break;
        case PhonePosition_Lying:
            value = 1;
            break;
        case PhonePosition_Standing:
            value = 0;
            break;
        default:
            break;
    }
    return value;
}

@end
