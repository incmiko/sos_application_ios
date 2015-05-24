//
//  GPSRequest.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "BaseRequest.h"
#import "GPSPosition.h"

@interface GPSRequest : BaseRequest

@property (nonatomic,strong) GPSPosition* gpsPosition;

@end
