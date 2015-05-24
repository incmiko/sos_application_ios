//
//  RegisterSensorObject.m
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 07..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import "SOSSensor.h"
#import "DataManager.h"

#define SENSOR_UNIQUE_NAME @"urn:ogc:object:feature:Sensor:52N:"
#define SENSOR_PHENOMENON @"urn:ogc:def:phenomenon:OGC:1.0.30:"
#define SENSOR_IDENTIFIER @"urn:ogc:object:feature:Sensor:"

#define DICT_KEY_TYPE @"type"
#define DICT_KEY_SENSOR_NAME @"sensorName"
#define DICT_KEY_SENSORLAST_MEASURED_POS_EAST @"sensorLast_Measured_Pos_east"
#define DICT_KEY_SENSORLAST_MEASURED_POS_NORTH @"sensorLast_Measured_Pos_north"
#define DICT_KEY_SENSORLAST_MEASURED_POS_ALTITUDE @"sensorLast_Measured_Pos_altitude"
#define DICT_KEY_SENSOR_VALUE_NAME @"sensorValueName"
#define DICT_KEY_SENSOR_VALUE_UNIT_TYPE @"sensorValue_unit_type"
#define DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_ID @"sensorValue_Output_Offering_ID"
#define DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_NAME @"sensorValue_Output_Offering_Name"
#define DICT_KEY_COMPONENT_ID_VALUE @"comp_ID_Val"
#define DICT_KEY_COMPONENT_INPUT_NAME @"component_input_name"
#define DICT_KEY_FOI @"FOI"
#define DICT_KEY_FOI_SAMPLING_POINT @"FOI_SamplingPoint"

@implementation SOSSensor

- (instancetype) init{
    
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSData*) getXMLDataWithWriteToFile:(bool)writeToFile{
    XMLWriter* writer = [XMLWriter sharedInstance];
    return [writer createSensorXMLData:self writeToFile:YES];
}

- (NSData*) getInsertData{
    XMLWriter* writer = [XMLWriter sharedInstance];
    
    NSString* value = nil;
    switch (self.type) {
        case SensorType_Magnetometer:
            value = [NSString stringWithFormat:@"%.2f",[DataManager sharedInstance].actualData.magneticHeading];
            break;
        case SensorType_Accelerometer:
            value = [NSString stringWithFormat:@"%f",[DataManager sharedInstance].actualData.acceleration];
            break;
        case SensorType_GYRO:
            value = [NSString stringWithFormat:@"%i",[[DataManager sharedInstance].actualData getIntValueOfPhonePosition]];
            break;
        default:
            break;
    }
    
    return [writer createInsertXMLData:self withValue:value];
}

- (void) setSensorName:(NSString *)sensorName{
    _sensorName = sensorName;
    _sensorUniqueName = [NSString stringWithFormat:@"%@%@",SENSOR_UNIQUE_NAME,_sensorName];
}

- (void) setSensorValueName:(NSString *)sensorValueName{
    _sensorValueName = sensorValueName;
    _sensorValue_observable_property = [NSString stringWithFormat:@"%@%@",SENSOR_PHENOMENON,_sensorValueName];
}

- (void) setComp_ID_Val:(NSString *)comp_ID_Val{
    _comp_ID_Val = comp_ID_Val;
    _component_identifier_value = [NSString stringWithFormat:@"%@%@",SENSOR_IDENTIFIER,_comp_ID_Val];
}

- (void) setComponent_input_name:(NSString *)component_input_name{
    _component_input_name = component_input_name;
    _component_input_observable_property = [NSString stringWithFormat:@"%@%@",SENSOR_PHENOMENON,_component_input_name];
}

- (NSString*) getFormattedFOIPosition{
    return [NSString stringWithFormat:@"%@ %@",_sensorLast_Measured_Pos_north,_sensorLast_Measured_Pos_east];
}

- (void) saveSensor{
    [[NSUserDefaults standardUserDefaults] setObject:[self createDictionary] forKey:[[SOSManager sharedInstance] getKeyForType:_type]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadSensor:(SensorType)type{
   NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:[[SOSManager sharedInstance] getKeyForType:type]];
    
    self.type = [[dict objectForKey:DICT_KEY_TYPE] intValue];
    self.sensorName = [dict objectForKey:DICT_KEY_SENSOR_NAME];
    self.sensorLast_Measured_Pos_east = [dict objectForKey:DICT_KEY_SENSORLAST_MEASURED_POS_EAST];
    self.sensorLast_Measured_Pos_north = [dict objectForKey:DICT_KEY_SENSORLAST_MEASURED_POS_NORTH];
    self.sensorLast_Measured_Pos_altitude = [dict objectForKey:DICT_KEY_SENSORLAST_MEASURED_POS_ALTITUDE];
    self.sensorValueName = [dict objectForKey:DICT_KEY_SENSOR_VALUE_NAME];
    self.sensorValue_unit_type = [dict objectForKey:DICT_KEY_SENSOR_VALUE_UNIT_TYPE];
    self.sensorValue_Output_Offering_ID = [dict objectForKey:DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_ID];
    self.sensorValue_Output_Offering_Name = [dict objectForKey:DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_NAME];
    self.comp_ID_Val = [dict objectForKey:DICT_KEY_COMPONENT_ID_VALUE];
    self.component_input_name = [dict objectForKey:DICT_KEY_COMPONENT_INPUT_NAME];
    self.FOI = [dict objectForKey:DICT_KEY_FOI];
    self.FOI_SamplingPoint = [dict objectForKey:DICT_KEY_FOI_SAMPLING_POINT];
}


- (NSDictionary*) createDictionary{
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[NSNumber numberWithInt:_type] forKey:DICT_KEY_TYPE];
    [dictionary setValue:_sensorName forKey:DICT_KEY_SENSOR_NAME];
    [dictionary setValue:_sensorLast_Measured_Pos_east forKey:DICT_KEY_SENSORLAST_MEASURED_POS_EAST];
    [dictionary setValue:_sensorLast_Measured_Pos_north forKey:DICT_KEY_SENSORLAST_MEASURED_POS_NORTH];
    [dictionary setValue:_sensorLast_Measured_Pos_altitude forKey:DICT_KEY_SENSORLAST_MEASURED_POS_ALTITUDE];
    [dictionary setValue:_sensorValueName forKey:DICT_KEY_SENSOR_VALUE_NAME];
    [dictionary setValue:_sensorValue_unit_type forKey:DICT_KEY_SENSOR_VALUE_UNIT_TYPE];
    [dictionary setValue:_sensorValue_Output_Offering_ID forKey:DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_ID];
    [dictionary setValue:_sensorValue_Output_Offering_Name forKey:DICT_KEY_SENSOR_VALUE_OUTPUT_OFFERING_NAME];
    [dictionary setValue:_comp_ID_Val forKey:DICT_KEY_COMPONENT_ID_VALUE];
    [dictionary setValue:_component_input_name forKey:DICT_KEY_COMPONENT_INPUT_NAME];
    [dictionary setValue:_FOI forKey:DICT_KEY_FOI];
    [dictionary setValue:_FOI_SamplingPoint forKey:DICT_KEY_FOI_SAMPLING_POINT];
    
    return dictionary;
}



@end
