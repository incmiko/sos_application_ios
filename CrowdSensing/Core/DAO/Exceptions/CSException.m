//
//  CSException.m
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 17..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import "CSException.h"

@implementation CSException

@synthesize error;

- (id) initWithServiceError:(ServiceError *)err{
    self = [self init];
    if (self) {
        error = err;
    }
    return self;
}

- (id) init {
    
    self = [super initWithName: nil reason: nil userInfo: nil];
    
    return self;
}

- (void) logError{
    TestLog(@"###### Exception type: %@ --- errorCode: %@  technicalMessage: %@",NSStringFromClass([self class]),[error getStringForCode],error.technicalMessage);
}

@end
