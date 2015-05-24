//
//  ServiceError.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ErrorCode_Unknown = -1,
    ErrorCode_No_Internet_Connection = 1,
    ErrorCode_Invalid_Response = 2,
    ErrorCode_Invalid_Request = 3,
    ErrorCode_Invalid_SOSSensor = 4,
    ErrorCode_Response_Exception = 5
}ErrorCode;

@interface ServiceError : NSObject

- (instancetype) initWithErrorCode:(ErrorCode)code userMessage:(NSString*)userM technicalMessage:(NSString*)technM;
- (NSString*) getStringForCode;

@property (nonatomic) ErrorCode errorCode;
@property (nonatomic,strong) NSString* userMessage;
@property (nonatomic,strong) NSString* technicalMessage;

@end
