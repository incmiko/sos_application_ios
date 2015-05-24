//
//  CSException.h
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 17..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceError.h"

@interface CSException : NSException

- (instancetype) initWithServiceError:(ServiceError*)err;

@property (nonatomic, strong) ServiceError* error;

- (void) logError;

@end
