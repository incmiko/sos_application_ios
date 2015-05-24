//
//  ServiceError.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "ServiceError.h"

@implementation ServiceError

@synthesize errorCode,userMessage,technicalMessage;

- (instancetype) initWithErrorCode:(ErrorCode)code userMessage:(NSString *)userM technicalMessage:(NSString *)technM{
    
    self = [super init];
    if (self) {
        
        errorCode = code;
        userMessage = userM;
        technicalMessage = technM;
        
    }
    return self;
}

- (NSString*) getStringForCode{
    
    switch (errorCode) {
        case ErrorCode_Unknown: return @"Unknown"; break;
        case ErrorCode_Invalid_Request: return @"Invalid_Request"; break;
        case ErrorCode_Invalid_Response: return @"Invalid_Response"; break;
        case ErrorCode_Invalid_SOSSensor: return @"Invalid_SOSSensor"; break;
        case ErrorCode_No_Internet_Connection: return @"No_Internet_Connection"; break;
        default: return @""; break;
    }
}

@end
