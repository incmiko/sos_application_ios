//
//  UpdatePushTokenRequest.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "BaseRequest.h"

@interface UpdatePushTokenRequest : BaseRequest

@property (nonatomic,strong) NSString* pushToken;

@end
