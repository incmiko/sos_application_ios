//
//  UploadVoiceRequest.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 30..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "GPSRequest.h"

@interface UploadVoiceRequest : GPSRequest

@property (nonatomic,strong) NSString* voice;
@property (nonatomic) int eventID;
@end
