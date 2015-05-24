//
//  BaseRequest.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enumerations.h"

@interface BaseRequest : NSObject

@property (nonatomic,strong) NSString* requestID;
@property (nonatomic,strong) NSString* deviceID;

@end
