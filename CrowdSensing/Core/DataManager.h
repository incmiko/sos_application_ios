//
//  DataManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CSData.h"

@interface DataManager : NSObject

+ (DataManager *) sharedInstance;

@property (nonatomic,strong) CSData* actualData;

- (void) updateLocationWithAcceleration:(bool)acc withGyroscope:(bool)gyro;

- (void) recordVoice;
- (void) stopRecord;

- (void) uploadImage:(UIImage*)image;

@end
