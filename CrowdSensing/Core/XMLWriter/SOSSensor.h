//
//  RegisterSensorObject.h
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 07..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLWriter.h"
#import "SOSManager.h"

@interface SOSSensor : NSObject

@property (nonatomic) SensorType type;

@property (nonatomic,retain) NSString* sensorName;
@property (nonatomic,retain) NSString* sensorUniqueName;

@property (nonatomic,retain) NSString* sensorLast_Measured_Pos_east;
@property (nonatomic,retain) NSString* sensorLast_Measured_Pos_north;
@property (nonatomic,retain) NSString* sensorLast_Measured_Pos_altitude;

@property (nonatomic,retain) NSString* sensorValueName;
@property (nonatomic,retain) NSString* sensorValue_observable_property;

@property (nonatomic,retain) NSString* sensorValue_unit_type;
@property (nonatomic,retain) NSString* sensorValue_Output_Offering_ID;
@property (nonatomic,retain) NSString* sensorValue_Output_Offering_Name;

@property (nonatomic,retain) NSString* comp_ID_Val;
@property (nonatomic,retain) NSString* component_identifier_value;

@property (nonatomic,retain) NSString* component_input_name;
@property (nonatomic,retain) NSString* component_input_observable_property;

@property (nonatomic,retain) NSString* FOI;
@property (nonatomic,retain) NSString* FOI_SamplingPoint;

- (NSString*) getFormattedFOIPosition;

- (NSData*) getXMLDataWithWriteToFile:(bool)writeToFile;
- (NSData*) getInsertData;

- (void) saveSensor;
- (void) loadSensor:(SensorType)type;

@end
