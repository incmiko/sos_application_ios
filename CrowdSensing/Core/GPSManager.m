//
//  GPSManager.m
//  CrowdSensing
//
//  Created by Mike on 2014. 12. 16..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "GPSManager.h"
#import "DataManager.h"
#import "LocationManager.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define DistanceFilter 0.

@interface GPSManager ()

@property (nonatomic) int distanceFilter;
@property (nonatomic) CLLocationCoordinate2D lastLocation;
@property (nonatomic) CLLocationAccuracy lastLocationAccuracy;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CLLocationAccuracy locationAccuracy;
@property (strong,nonatomic) LocationManager * sharedLocationManager;

@end

@implementation GPSManager

@synthesize distanceFilter,lastLocation,lastLocationAccuracy,location,locationAccuracy,sharedLocationManager;
@synthesize delegate;

+ (CLLocationManager *)sharedInstance {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        }
    }
    return _locationManager;
}

- (id)init {
    if (self==[super init]) {
        
        distanceFilter = DistanceFilter;
        sharedLocationManager = [LocationManager sharedInstance];
        sharedLocationManager.myLocationArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void) startHeadingTracking{
    CLLocationManager *locationManager = [GPSManager sharedInstance];
    if (locationManager.delegate != self)
        locationManager.delegate = self;
    
    [locationManager startUpdatingHeading];

}

- (void) stopHeadingTracking{
    CLLocationManager *locationManager = [GPSManager sharedInstance];
    [locationManager stopUpdatingHeading];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [DataManager sharedInstance].actualData.magneticHeading = newHeading.magneticHeading;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEGREE_TO_NORTH_CHANGED object:self userInfo:nil];

}


- (void)startLocationTracking {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            TestLog(@"authorizationStatus failed");
        } else {
            CLLocationManager *locationManager = [GPSManager sharedInstance];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = distanceFilter;
            SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:requestSelector])
                [locationManager performSelector:requestSelector withObject:NULL];
            
            [locationManager startUpdatingLocation];
        }
    }
}


- (void)stopLocationTracking {
    if (sharedLocationManager.timer) {
        [sharedLocationManager.timer invalidate];
        sharedLocationManager.timer = nil;
    }
    
    CLLocationManager *locationManager = [GPSManager sharedInstance];
    [locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 10.0)
        {
            CLLocationManager *locationManager = [GPSManager sharedInstance];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:requestSelector])
                [locationManager performSelector:requestSelector withObject:NULL];
            [locationManager startUpdatingLocation];
            return;
        }
        
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            lastLocation = theLocation;
            lastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:newLocation.altitude] forKey:@"altitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            [sharedLocationManager.myLocationArray addObject:dict];
        }
        else{
            CLLocationManager *locationManager = [GPSManager sharedInstance];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:requestSelector])
                [locationManager performSelector:requestSelector withObject:NULL];
            
            [locationManager startUpdatingLocation];
            return;
        }
    }
    
    // Looking for the best location
    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    
    for(int i=0;i<sharedLocationManager.myLocationArray.count;i++){
        NSMutableDictionary * currentLocation = [sharedLocationManager.myLocationArray objectAtIndex:i];
        
        if(i==0)
            myBestLocation = currentLocation;
        else{
            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
                myBestLocation = currentLocation;
            }
        }
    }
    
    [self updateLocationData];
    
    if (sharedLocationManager.timer) {
        return;
    }
    
    sharedLocationManager.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [sharedLocationManager.bgTask beginNewBackgroundTask];
}

- (void)updateLocationData {
    
    // Find the best location from the array based on accuracy
    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    
    for(int i=0;i<sharedLocationManager.myLocationArray.count;i++){
        NSMutableDictionary * currentLocation = [sharedLocationManager.myLocationArray objectAtIndex:i];
        
        if(i==0)
            myBestLocation = currentLocation;
        else{
            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
                myBestLocation = currentLocation;
            }
        }
    }
    
    if ([myBestLocation objectForKey:@"latitude"])
        [DataManager sharedInstance].actualData.gpsPosition.latitude = [[myBestLocation objectForKey:@"latitude"] floatValue];
    
    if ([myBestLocation objectForKey:@"longitude"])
        [DataManager sharedInstance].actualData.gpsPosition.longitude = [[myBestLocation objectForKey:@"longitude"] floatValue];
    
    if ([myBestLocation objectForKey:@"altitude"])
        [DataManager sharedInstance].actualData.gpsPosition.altitude = [[myBestLocation objectForKey:@"altitude"] floatValue];
    
    if (delegate && [delegate respondsToSelector:@selector(locationUpdated)]) {
        [delegate locationUpdated];
    }
    
    if(sharedLocationManager.myLocationArray.count==0)
    {
        // there isn't any new location
        location = lastLocation;
        locationAccuracy = lastLocationAccuracy;
        
    }else{
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
        location=theBestLocation;
        locationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
    }
    
    [sharedLocationManager.myLocationArray removeAllObjects];
    sharedLocationManager.myLocationArray = nil;
    sharedLocationManager.myLocationArray = [[NSMutableArray alloc]init];
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    
    switch([error code])
    {
        case kCLErrorNetwork:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


#pragma mark - Background

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [GPSManager sharedInstance];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = distanceFilter;
    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:requestSelector])
        [locationManager performSelector:requestSelector withObject:NULL];
    
    [locationManager startUpdatingLocation];
    
    sharedLocationManager.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [sharedLocationManager.bgTask beginNewBackgroundTask];
}

@end
