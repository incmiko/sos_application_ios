//
//  BaseResponse.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceError.h"
#import "Enumerations.h"

@interface BaseResponse : NSObject

@property (nonatomic,strong) NSString* requestID;
@property (nonatomic,strong) NSString* deviceID;
@property (nonatomic,strong) ServiceError* error;

@end
