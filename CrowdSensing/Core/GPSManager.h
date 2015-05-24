//
//  GPSManager.h
//  CrowdSensing
//
//  Created by Mike on 2014. 12. 16..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GPSManagerDelegate <NSObject>

@required

- (void) locationUpdated;

@end

@interface GPSManager : NSObject <CLLocationManagerDelegate>

+ (CLLocationManager *)sharedInstance;

- (void) startLocationTracking;
- (void) stopLocationTracking;

- (void) startHeadingTracking;
- (void) stopHeadingTracking;

@property (nonatomic,weak) id<GPSManagerDelegate> delegate;

@end
