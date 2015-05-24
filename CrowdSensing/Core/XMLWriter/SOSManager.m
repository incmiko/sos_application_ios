//
//  SOSManager.m
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 09..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import "SOSManager.h"
#import "SOSSensor.h"
#import "CommunicationManager.h"
#import "DataManager.h"

@interface SOSManager ()<CommunicationManagerDelegate>

@property (nonatomic,retain) NSMutableArray* SOSSensors;

@end

@implementation SOSManager

@synthesize SOSSensors;

static SOSManager *sharedInstance;

+ (SOSManager *) sharedInstance {
    
    if (!sharedInstance)
        sharedInstance = [[SOSManager alloc] init];
    
    return sharedInstance;
}

- (instancetype) init{
    
    self = [super init];
    if (self) {
        SOSSensors = [[NSMutableArray alloc]init];
    }
    
    return self;
}

// ------------------------------------------------------------------------- //
// ------------------------------ REGISTRATION ------------------------------ //


- (void) registerUnregisteredSensors{
    if (![[SOSManager sharedInstance] detectSensorIsRegistered:SensorType_Magnetometer]) {
        [[SOSManager sharedInstance] registerSensorForType:SensorType_Magnetometer];
    }
    if (![[SOSManager sharedInstance] detectSensorIsRegistered:SensorType_Accelerometer]) {
        [[SOSManager sharedInstance] registerSensorForType:SensorType_Accelerometer];
    }
    if (![[SOSManager sharedInstance] detectSensorIsRegistered:SensorType_GYRO]) {
        [[SOSManager sharedInstance] registerSensorForType:SensorType_GYRO];
    }
}

- (void) registerSensorForType:(SensorType)type{
    
    if ([self detectSensorIsRegistered:type]){
        NSLog(@"########### A sensor with this type is already registered.");
        return;
    }
    
    SOSSensor* sensor = [self createSensorForType:type];
    [[CommunicationManager sharedInstance] registerSensor:sensor withDelegate:self];
}

#pragma mark conforms to Communication Manager

- (void) registrationWasSuccessful:(SOSSensor *)sensor{
    [sensor saveSensor];
    [SOSSensors addObject:sensor];
    
    if ([self allSensorsRegistered]) {
        [[DataManager sharedInstance] updateLocationWithAcceleration:YES withGyroscope:YES];
    }
}
- (void) registrationFailed:(SOSSensor *)sensor withException:(CSException *)ex{
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong" message:[NSString stringWithFormat:@"An error occured during the sensor registration: %@ ## %@",[[SOSManager sharedInstance] getKeyForType:sensor.type],ex.error.technicalMessage] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

// ------------------------------------------------------------------------- //
// ------------------------------ LOAD/CREATE ------------------------------ //

- (void) loadSOSSensors{
    
    [self loadSOSSensorForType:SensorType_Magnetometer];
    [self loadSOSSensorForType:SensorType_Accelerometer];
    [self loadSOSSensorForType:SensorType_GYRO];
    NSLog(@"");
}

- (void) loadSOSSensorForType:(SensorType)type{
    
    if ([self findSOSSensorForType:type]) {
        NSLog(@"########### A sensor with this type (TYPE: %@) is already loaded.",[self getKeyForType:type]);
        return;
    }
    
    if (![self detectSensorIsRegistered:type]){
        NSLog(@"########### There isn't any sensor registered with this type (TYPE: %@)",[self getKeyForType:type]);
        return;
    }
        
    SOSSensor* sensor = [[SOSSensor alloc]init];
    [sensor loadSensor:type];
    [SOSSensors addObject:sensor];
}

- (SOSSensor*) createSensorForType:(SensorType)type{
 
    SOSSensor* sensor = [[SOSSensor alloc]init];
    sensor.type = type;
    sensor.sensorName = [self getSensorNameForType:type];
    sensor.sensorLast_Measured_Pos_north = @"47.497912"; // latitude
    sensor.sensorLast_Measured_Pos_east = @"19.040235"; // longitude
    sensor.sensorLast_Measured_Pos_altitude = @"0.0";
    sensor.sensorValueName = [NSString stringWithFormat:@"%@_value",[self getTextForType:type]];
    sensor.sensorValue_unit_type = [self getUnitTypeForType:type];
    sensor.sensorValue_Output_Offering_ID = [[self getTextForType:type] uppercaseString];
    sensor.sensorValue_Output_Offering_Name = [NSString stringWithFormat:@"%@: %@",[self getTextForType:type],[self getUnitTypeForType:type]];
    sensor.comp_ID_Val = [NSString stringWithFormat:@"%@_sensor",[self getTextForType:type]];
    sensor.component_input_name = [self getTextForType:type];
    sensor.FOI = [NSString stringWithFormat:@"foi_%@",[self getTextForType:type]];
    sensor.FOI_SamplingPoint = [NSString stringWithFormat:@"%@_SamplingPoint_%@",[self getTextForType:type],[[CommunicationManager sharedInstance] getDeviceID]];
    return sensor;
}

// ------------------------------------------------------------------- //
// ----------------------------- UPDATE ------------------------------ //

- (void) updateSensorsPosition:(GPSPosition*)position{
    for (SOSSensor* sensor in SOSSensors) {
        sensor.sensorLast_Measured_Pos_north = [NSString stringWithFormat:@"%f",position.latitude];
        sensor.sensorLast_Measured_Pos_east = [NSString stringWithFormat:@"%f",position.longitude];
        sensor.sensorLast_Measured_Pos_altitude = [NSString stringWithFormat:@"%f",position.altitude];
    }
}

// ------------------------------------------------------------------- //
// ------------------------------ UTILS ------------------------------ //

- (bool) detectSensorIsRegistered:(SensorType)type{
    
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:[self getKeyForType:type]];
    if (dict)
        return YES;
    
    return NO;
}

- (bool) allSensorsRegistered{
    
    if (![self detectSensorIsRegistered:SensorType_Magnetometer] || ![self detectSensorIsRegistered:SensorType_Accelerometer] || ![self detectSensorIsRegistered:SensorType_GYRO])
        return NO;
    
    return YES;
}

- (NSString*) getKeyForType:(SensorType)type{
    NSString* theKey = nil;
    switch (type) {
        case SensorType_Magnetometer:
            theKey = SENSOR_MAGNETOMETER;
            break;
        case SensorType_Accelerometer:
            theKey = SENSOR_ACCELEROMETER;
            break;
        case SensorType_GYRO:
            theKey = SENSOR_GYROSCOPE;
            break;
        default:
            break;
    }
    return theKey;
}

- (SOSSensor*) findSOSSensorForType:(SensorType)type{
    
    for (SOSSensor* sossensor in SOSSensors)
        if (sossensor.type == type)
            return sossensor;
    
    return nil;
}


- (NSString*) getSensorNameForType:(SensorType)type{
    NSString* sensorName = nil;
    
    switch (type) {
        case SensorType_Accelerometer:
            sensorName = @"accelerometer";
            break;
        case SensorType_GYRO:
            sensorName = @"gyroscope";
            break;
        case SensorType_Magnetometer:
            sensorName = @"magnetometer";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@_%@",sensorName,[[CommunicationManager sharedInstance] getDeviceID]];
}

- (NSString*)getTextForType:(SensorType)type{
    switch (type) {
        case SensorType_Accelerometer:
            return @"acceleration";
            break;
        case SensorType_Magnetometer:
            return @"heading";
            break;
        case SensorType_GYRO:
            return @"tilt";
            break;
        default:
            break;
    }
}
- (NSString*) getUnitTypeForType:(SensorType)type{
    switch (type) {
        case SensorType_Accelerometer:
            return @"m/s/s";
            break;
        case SensorType_Magnetometer:
            return @"degree";
            break;
        case SensorType_GYRO:
            return @"degree";
            break;
        default:
            break;
    }
}

@end
