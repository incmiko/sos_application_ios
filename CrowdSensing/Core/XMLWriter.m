//
//  XMLWriter.m
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 07..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import "XMLWriter.h"
#import "GDataXMLNode.h"

/* RegisterSensor
 version="1.0.0"
 xmlns="http://www.opengis.net/sos/1.0" 
 xmlns:swe="http://www.opengis.net/swe/1.0.1"
 xmlns:sa="http://www.opengis.net/sampling/1.0" 
 xmlns:ows="http://www.opengeospatial.net/ows"
 xmlns:xlink="http://www.w3.org/1999/xlink" 
 xmlns:gml="http://www.opengis.net/gml"
 xmlns:ogc="http://www.opengis.net/ogc" 
 xmlns:om="http://www.opengis.net/om/1.0"
 xmlns:sml="http://www.opengis.net/sensorML/1.0.1" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.opengis.net/sos/1.0
 http://schemas.opengis.net/sos/1.0.0/sosRegisterSensor.xsd
 http://www.opengis.net/om/1.0
 http://schemas.opengis.net/om/1.0.0/extensions/observationSpecialization_override.xsd"
 */

/* InsertObservation
 xmlns="http://www.opengis.net/sos/1.0"
	xmlns:ows="http://www.opengis.net/ows/1.1"
	xmlns:ogc="http://www.opengis.net/ogc"
	xmlns:om="http://www.opengis.net/om/1.0"
	xmlns:sos="http://www.opengis.net/sos/1.0"
	xmlns:sa="http://www.opengis.net/sampling/1.0"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:swe="http://www.opengis.net/swe/1.0.1"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.opengis.net/sos/1.0
	http://schemas.opengis.net/sos/1.0.0/sosInsert.xsd
	http://www.opengis.net/sampling/1.0
	http://schemas.opengis.net/sampling/1.0.0/sampling.xsd
	http://www.opengis.net/om/1.0
	http://schemas.opengis.net/om/1.0.0/extensions/observationSpecialization_override.xsd"
	service="SOS" version="1.0.0"
 */

#define INSERT_OBSERVATION_HEADER_ATTRIBUTE_KEYS @"xmlns",\
@"xmlns:ows",\
@"xmlns:ogc",\
@"xmlns:om",\
@"xmlns:sos",\
@"xmlns:sa",\
@"xmlns:gml",\
@"xmlns:swe",\
@"xmlns:xlink",\
@"xmlns:xsi",\
@"xsi:schemaLocation",\
@"service",\
@"version"

#define INSERT_OBSERVATION_HEADER_ATTRIBUTE_VALUES @"http://www.opengis.net/sos/1.0",\
@"http://www.opengis.net/ows/1.1",\
@"http://www.opengis.net/ogc",\
@"http://www.opengis.net/om/1.0",\
@"http://www.opengis.net/sos/1.0",\
@"http://www.opengis.net/sampling/1.0",\
@"http://www.opengis.net/gml",\
@"http://www.opengis.net/swe/1.0.1",\
@"http://www.w3.org/1999/xlink",\
@"http://www.w3.org/2001/XMLSchema-instance",\
@"http://www.opengis.net/sos/1.0 http://schemas.opengis.net/sos/1.0.0/sosInsert.xsd http://www.opengis.net/sampling/1.0 http://schemas.opengis.net/sampling/1.0.0/sampling.xsd http://www.opengis.net/om/1.0 http://schemas.opengis.net/om/1.0.0/extensions/observationSpecialization_override.xsd",\
@"SOS",\
@"1.0.0"

#define REGISTER_SENSOR_HEADER_ATTRIBUTE_KEYS @"service",\
@"version",\
@"xmlns",\
@"xmlns:swe",\
@"xmlns:sa",\
@"xmlns:ows",\
@"xmlns:xlink",\
@"xmlns:gml",\
@"xmlns:ogc",\
@"xmlns:om",\
@"xmlns:sml",\
@"xmlns:xsi",\
@"xsi:schemaLocation"

#define REGISTER_SENSOR_HEADER_ATTRIBUTE_VALUES @"SOS",\
@"1.0.0",\
@"http://www.opengis.net/sos/1.0",\
@"http://www.opengis.net/swe/1.0.1",\
@"http://www.opengis.net/sampling/1.0",\
@"http://www.opengeospatial.net/ows",\
@"http://www.w3.org/1999/xlink",\
@"http://www.opengis.net/gml",\
@"http://www.opengis.net/ogc",\
@"http://www.opengis.net/om/1.0",\
@"http://www.opengis.net/sensorML/1.0.1",\
@"http://www.w3.org/2001/XMLSchema-instance",\
@"http://www.opengis.net/sos/1.0 http://schemas.opengis.net/sos/1.0.0/sosRegisterSensor.xsd http://www.opengis.net/om/1.0 http://schemas.opengis.net/om/1.0.0/extensions/observationSpecialization_override.xsd"

@implementation XMLWriter

static XMLWriter *sharedInstance;

+ (XMLWriter *) sharedInstance {
    
    if (!sharedInstance)
        sharedInstance = [[XMLWriter alloc] init];
    
    return sharedInstance;
}

- (NSData*) createSensorXMLData:(SOSSensor *)newSensor writeToFile:(bool)write{
    
    // ------------------- REGISTER SENSOR ---- HEADER ------------------- //
    
    NSArray* reg_Header_Keys = [NSArray arrayWithObjects:REGISTER_SENSOR_HEADER_ATTRIBUTE_KEYS, nil];
    NSArray* reg_Header_Values = [NSArray arrayWithObjects:REGISTER_SENSOR_HEADER_ATTRIBUTE_VALUES, nil];

    GDataXMLElement * registerSensor = [GDataXMLNode elementWithName:@"RegisterSensor"];
    for (int i = 0; i < reg_Header_Keys.count; i++) {
        GDataXMLNode* attribute = [GDataXMLNode attributeWithName:reg_Header_Keys[i] stringValue:reg_Header_Values[i]];
        [registerSensor addAttribute:attribute];
    }

    // ------------------- REGISTER SENSOR ---- SensorDescription ------------------- //
    // <!-- Sensor Description parameter; Currently, this has to be a sml:System -->
    
    GDataXMLElement * sensorDescription = [GDataXMLNode elementWithName:@"SensorDescription"];
    
    GDataXMLElement * sml_SensorML = [GDataXMLNode elementWithName:@"sml:SensorML"];
    GDataXMLNode* sml_SensorML_attribute = [GDataXMLNode attributeWithName:@"version" stringValue:@"1.0.1"];
    [sml_SensorML addAttribute:sml_SensorML_attribute];
    
    GDataXMLElement * sml_member = [GDataXMLNode elementWithName:@"sml:member"];
    GDataXMLElement * sml_System = [GDataXMLNode elementWithName:@"sml:System"];
    [sml_System addAttribute:[GDataXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
    
    // IDENTIFIER
    // <!--sml:identification element must contain the ID of the sensor -->
    GDataXMLElement * sml_identification = [GDataXMLNode elementWithName:@"sml:identification"];
    
    GDataXMLElement * sml_IdentifierList = [GDataXMLNode elementWithName:@"sml:IdentifierList"];
    GDataXMLElement * sml_identifier = [GDataXMLNode elementWithName:@"sml:identifier"];
    GDataXMLElement * sml_Term = [GDataXMLNode elementWithName:@"sml:Term"];
    [sml_Term addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:@"urn:ogc:def:identifier:OGC:uniqueID"]];
    
    GDataXMLElement * sml_value = [GDataXMLNode elementWithName:@"sml:value" stringValue:newSensor.sensorUniqueName];

    [sml_Term addChild:sml_value];
    [sml_identifier addChild:sml_Term];
    [sml_IdentifierList addChild:sml_identifier];
    [sml_identification addChild:sml_IdentifierList];
    
    
    // POSITION
    // <!-- last measured position of sensor -->
    GDataXMLElement * sml_position = [GDataXMLNode elementWithName:@"sml:position"];
    [sml_position addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:@"sensorPosition"]];

    GDataXMLElement * swe_Position = [GDataXMLNode elementWithName:@"swe:Position"];
    [swe_Position addAttribute:[GDataXMLNode attributeWithName:@"referenceFrame" stringValue:@"urn:ogc:def:crs:EPSG::4326"]];
    GDataXMLElement * swe_location = [GDataXMLNode elementWithName:@"swe:location"];
    GDataXMLElement * swe_Vector = [GDataXMLNode elementWithName:@"swe:Vector"];
    [swe_Vector addAttribute:[GDataXMLNode attributeWithName:@"gml:id" stringValue:@"STATION_LOCATION"]];

    // EAST
    GDataXMLElement * swe_coordinate_east = [GDataXMLNode elementWithName:@"swe:coordinate"];
    [swe_coordinate_east addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:@"easting"]];
    
    GDataXMLElement * swe_Quantity_east = [GDataXMLNode elementWithName:@"swe:Quantity"];
    GDataXMLElement * swe_uom_east = [GDataXMLNode elementWithName:@"swe:uom"];
    [swe_uom_east addAttribute:[GDataXMLNode attributeWithName:@"code" stringValue:@"degree"]];
    GDataXMLElement * swe_value_east = [GDataXMLNode elementWithName:@"swe:value" stringValue:newSensor.sensorLast_Measured_Pos_east];

    [swe_Quantity_east addChild:swe_uom_east];
    [swe_Quantity_east addChild:swe_value_east];
    [swe_coordinate_east addChild:swe_Quantity_east];
    
    // NORTH
    GDataXMLElement * swe_coordinate_north = [GDataXMLNode elementWithName:@"swe:coordinate"];
    [swe_coordinate_north addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:@"northing"]];
    
    GDataXMLElement * swe_Quantity_north = [GDataXMLNode elementWithName:@"swe:Quantity"];
    GDataXMLElement * swe_uom_north = [GDataXMLNode elementWithName:@"swe:uom"];
    [swe_uom_north addAttribute:[GDataXMLNode attributeWithName:@"code" stringValue:@"degree"]];
    GDataXMLElement * swe_value_north = [GDataXMLNode elementWithName:@"swe:value" stringValue:newSensor.sensorLast_Measured_Pos_north];
    
    [swe_Quantity_north addChild:swe_uom_north];
    [swe_Quantity_north addChild:swe_value_north];
    [swe_coordinate_north addChild:swe_Quantity_north];
    
    // ALTITUDE
    GDataXMLElement * swe_coordinate_altitude = [GDataXMLNode elementWithName:@"swe:coordinate"];
    [swe_coordinate_altitude addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:@"altitude"]];

    GDataXMLElement * swe_Quantity_altitude = [GDataXMLNode elementWithName:@"swe:Quantity"];
    GDataXMLElement * swe_uom_altitude = [GDataXMLNode elementWithName:@"swe:uom"];
    [swe_uom_altitude addAttribute:[GDataXMLNode attributeWithName:@"code" stringValue:@"m"]];
    GDataXMLElement * swe_value_altitude = [GDataXMLNode elementWithName:@"swe:value" stringValue:newSensor.sensorLast_Measured_Pos_altitude];
    
    [swe_Quantity_altitude addChild:swe_uom_altitude];
    [swe_Quantity_altitude addChild:swe_value_altitude];
    [swe_coordinate_altitude addChild:swe_Quantity_altitude];
    
    // ----- adding coordinates
    [swe_Vector addChild:swe_coordinate_east];
    [swe_Vector addChild:swe_coordinate_north];
    [swe_Vector addChild:swe_coordinate_altitude];

    [swe_location addChild:swe_Vector];
    [swe_Position addChild:swe_location];
    [sml_position addChild:swe_Position];
    
    // INPUTS
    GDataXMLElement * sml_inputs = [GDataXMLNode elementWithName:@"sml:inputs"];
    GDataXMLElement * sml_InputList = [GDataXMLNode elementWithName:@"sml:InputList"];
    GDataXMLElement * sml_input = [GDataXMLNode elementWithName:@"sml:input"];
    [sml_input addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:newSensor.sensorValueName]];
    GDataXMLElement * swe_ObservableProperty = [GDataXMLNode elementWithName:@"swe:ObservableProperty"];
    [swe_ObservableProperty addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:newSensor.sensorValue_observable_property]];

    [sml_input addChild:swe_ObservableProperty];
    [sml_InputList addChild:sml_input];
    [sml_inputs addChild:sml_InputList];
    
    // OUTPUTS
    GDataXMLElement * sml_outputs = [GDataXMLNode elementWithName:@"sml:outputs"];
    GDataXMLElement * sml_OutputList = [GDataXMLNode elementWithName:@"sml:OutputList"];
    GDataXMLElement * sml_output = [GDataXMLNode elementWithName:@"sml:output"];
    [sml_output addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:newSensor.sensorValueName]];
    
    GDataXMLElement * swe_Quantity_output = [GDataXMLNode elementWithName:@"swe:Quantity"];
    [swe_Quantity_output addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:newSensor.sensorValue_observable_property]];
    
    GDataXMLElement * gml_metaDataProperty = [GDataXMLNode elementWithName:@"gml:metaDataProperty"];

    GDataXMLElement * offering = [GDataXMLNode elementWithName:@"offering"];
    GDataXMLElement * offering_id = [GDataXMLNode elementWithName:@"id" stringValue:newSensor.sensorValue_Output_Offering_ID];
    GDataXMLElement * offering_name = [GDataXMLNode elementWithName:@"name" stringValue:newSensor.sensorValue_Output_Offering_Name];

    [offering addChild:offering_id];
    [offering addChild:offering_name];
    [gml_metaDataProperty addChild:offering];
    
    GDataXMLElement * swe_uom_output = [GDataXMLNode elementWithName:@"swe:uom"];
    [swe_uom_output addAttribute:[GDataXMLNode attributeWithName:@"code" stringValue:newSensor.sensorValue_unit_type]];

    [swe_Quantity_output addChild:gml_metaDataProperty];
    [swe_Quantity_output addChild:swe_uom_output];
    [sml_output addChild:swe_Quantity_output];
    [sml_OutputList addChild:sml_output];
    [sml_outputs addChild:sml_OutputList];
    
    // COMPONENTS
    GDataXMLElement * sml_components = [GDataXMLNode elementWithName:@"sml:components"];
    GDataXMLElement * sml_ComponentList = [GDataXMLNode elementWithName:@"sml:ComponentList"];
    GDataXMLElement * sml_component = [GDataXMLNode elementWithName:@"sml:component"];
    [sml_component addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:@"gaugeSensor"]];
    GDataXMLElement * sml_Component = [GDataXMLNode elementWithName:@"sml:Component"];

    // identification
    GDataXMLElement * sml_identification_components = [GDataXMLNode elementWithName:@"sml:identification"];
    GDataXMLElement * sml_IdentifierList_components = [GDataXMLNode elementWithName:@"sml:IdentifierList"];
    GDataXMLElement * sml_identifier_components = [GDataXMLNode elementWithName:@"sml:identifier"];
    GDataXMLElement * sml_Term_components = [GDataXMLNode elementWithName:@"sml:Term"];
    [sml_Term_components addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:@"urn:ogc:def:identifier:OGC:uniqueID"]];
    GDataXMLElement * sml_value_components = [GDataXMLNode elementWithName:@"sml:value" stringValue:newSensor.component_identifier_value];

    [sml_Term_components addChild:sml_value_components];
    [sml_identifier_components addChild:sml_Term_components];
    [sml_IdentifierList_components addChild:sml_identifier_components];
    [sml_identification_components addChild:sml_IdentifierList_components];
    
    // inputs
    GDataXMLElement * sml_inputs_components = [GDataXMLNode elementWithName:@"sml:inputs"];
    GDataXMLElement * sml_InputList_components = [GDataXMLNode elementWithName:@"sml:InputList"];
    GDataXMLElement * sml_input_components = [GDataXMLNode elementWithName:@"sml:input"];
    [sml_input_components addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:newSensor.component_input_name]];
    GDataXMLElement * swe_ObservableProperty_components = [GDataXMLNode elementWithName:@"swe:ObservableProperty"];
    [swe_ObservableProperty_components addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:newSensor.component_input_observable_property]];
    
    [sml_input_components addChild:swe_ObservableProperty_components];
    [sml_InputList_components addChild:sml_input_components];
    [sml_inputs_components addChild:sml_InputList_components];
    
    // outputs
    GDataXMLElement * sml_outputs_components = [GDataXMLNode elementWithName:@"sml:outputs"];
    GDataXMLElement * sml_OutputList_components = [GDataXMLNode elementWithName:@"sml:OutputList"];
    GDataXMLElement * sml_output_components = [GDataXMLNode elementWithName:@"sml:output"];
    [sml_output_components addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:newSensor.component_input_name]];
    GDataXMLElement * swe_Quantity_components = [GDataXMLNode elementWithName:@"swe:Quantity"];
    [swe_Quantity_components addAttribute:[GDataXMLNode attributeWithName:@"definition" stringValue:newSensor.component_input_observable_property]];
    GDataXMLElement * swe_uom_components = [GDataXMLNode elementWithName:@"swe:uom"];
    [swe_uom_components addAttribute:[GDataXMLNode attributeWithName:@"code" stringValue:newSensor.sensorValue_unit_type]];

    [swe_Quantity_components addChild:swe_uom_components];
    [sml_output_components addChild:swe_Quantity_components];
    [sml_OutputList_components addChild:sml_output_components];
    [sml_outputs_components addChild:sml_OutputList_components];
    
    [sml_Component addChild:sml_identification_components];
    [sml_Component addChild:sml_inputs_components];
    [sml_Component addChild:sml_outputs_components];
    
    [sml_component addChild:sml_Component];
    [sml_ComponentList addChild:sml_component];
    [sml_components addChild:sml_ComponentList];

    [sml_System addChild:sml_identification];
    [sml_System addChild:sml_position];
    [sml_System addChild:sml_inputs];
    [sml_System addChild:sml_outputs];
    [sml_System addChild:sml_components];
    
    [sml_member addChild:sml_System];
    [sml_SensorML addChild:sml_member];
    [sensorDescription addChild:sml_SensorML];
    [registerSensor addChild:sensorDescription];
    
    // ------------------- REGISTER SENSOR ---- ObservationTemplate ------------------- //
    
    GDataXMLElement * observationTemplate = [GDataXMLNode elementWithName:@"ObservationTemplate"];
    GDataXMLElement * om_Measurement = [GDataXMLNode elementWithName:@"om:Measurement"];
    
    // measurement datas
    GDataXMLElement * om_samplingTime = [GDataXMLNode elementWithName:@"om:samplingTime"];
    GDataXMLElement * om_procedure = [GDataXMLNode elementWithName:@"om:procedure"];
    GDataXMLElement * om_observedProperty = [GDataXMLNode elementWithName:@"om:observedProperty"];
    
    // FOI register
    GDataXMLElement * om_featureOfInterest = [GDataXMLNode elementWithName:@"om:featureOfInterest"];
    GDataXMLElement * sa_SamplingPoint = [GDataXMLNode elementWithName:@"sa:SamplingPoint"];
    [sa_SamplingPoint addAttribute:[GDataXMLNode attributeWithName:@"gml:id" stringValue:newSensor.FOI]];

    GDataXMLElement * gml_name = [GDataXMLNode elementWithName:@"gml:name" stringValue:newSensor.FOI_SamplingPoint];
    GDataXMLElement * sa_sampledFeature = [GDataXMLNode elementWithName:@"sa:sampledFeature"];
    GDataXMLElement * sa_position = [GDataXMLNode elementWithName:@"sa:position"];
    
    GDataXMLElement * gml_Point = [GDataXMLNode elementWithName:@"gml:Point"];
    GDataXMLElement * gml_pos = [GDataXMLNode elementWithName:@"gml:pos" stringValue:[newSensor getFormattedFOIPosition]];
    [gml_pos addAttribute:[GDataXMLNode attributeWithName:@"srsName" stringValue:@"urn:ogc:def:crs:EPSG::4326"]];

    [gml_Point addChild:gml_pos];
    [sa_position addChild:gml_Point];
    
    [sa_SamplingPoint addChild:gml_name];
    [sa_SamplingPoint addChild:sa_sampledFeature];
    [sa_SamplingPoint addChild:sa_position];
    [om_featureOfInterest addChild:sa_SamplingPoint];
    
    GDataXMLElement * om_result = [GDataXMLNode elementWithName:@"om:result" stringValue:@"1.0"];
    [om_result addAttribute:[GDataXMLNode attributeWithName:@"xsi:type" stringValue:@"gml:MeasureType"]];
    [om_result addAttribute:[GDataXMLNode attributeWithName:@"uom" stringValue:@""]];

    [om_Measurement addChild:om_samplingTime];
    [om_Measurement addChild:om_procedure];
    [om_Measurement addChild:om_observedProperty];
    [om_Measurement addChild:om_featureOfInterest];
    [om_Measurement addChild:om_result];
    
    [observationTemplate addChild:om_Measurement];
    [registerSensor addChild:observationTemplate];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:registerSensor];
    NSData *xmlData = document.XMLData;
    
    if (write) {
        NSString *filePath = [self dataFilePath:TRUE withName:@"RegisterSensor" type:@"xml"];
        NSLog(@"Saving xml data to %@...", filePath);
        [xmlData writeToFile:filePath atomically:YES];
    }
    return xmlData;
}

- (NSData*) createInsertXMLData:(SOSSensor *)sensor withValue:(NSString *)value{
    
    GDataXMLElement * insertObservation = [GDataXMLNode elementWithName:@"InsertObservation"];
    
    NSArray* insert_Header_Keys = [NSArray arrayWithObjects:INSERT_OBSERVATION_HEADER_ATTRIBUTE_KEYS, nil];
    NSArray* insert_Header_Values = [NSArray arrayWithObjects:INSERT_OBSERVATION_HEADER_ATTRIBUTE_VALUES, nil];
    
    for (int i = 0; i < insert_Header_Keys.count; i++) {
        GDataXMLNode* attribute = [GDataXMLNode attributeWithName:insert_Header_Keys[i] stringValue:insert_Header_Values[i]];
        [insertObservation addAttribute:attribute];
    }
    
    GDataXMLElement * assignedSensorId = [GDataXMLNode elementWithName:@"AssignedSensorId" stringValue:sensor.sensorUniqueName];
    GDataXMLElement * om_Measurement = [GDataXMLNode elementWithName:@"om:Measurement"];
    
    // Sampling time
    GDataXMLElement * om_samplingTime = [GDataXMLNode elementWithName:@"om:samplingTime"];
    
    GDataXMLElement * gml_TimeInstant = [GDataXMLNode elementWithName:@"gml:TimeInstant"];
    GDataXMLElement * gml_timePosition = [GDataXMLNode elementWithName:@"gml:timePosition" stringValue:[self getFormattedTimeStamp]];
    [gml_TimeInstant addChild:gml_timePosition];
    [om_samplingTime addChild:gml_TimeInstant];
    
    // ------
    GDataXMLElement * om_procedure = [GDataXMLNode elementWithName:@"om:procedure"];
    [om_procedure addAttribute:[GDataXMLNode attributeWithName:@"xlink:href" stringValue:sensor.sensorUniqueName]];
    
    GDataXMLElement * om_observedProperty = [GDataXMLNode elementWithName:@"om:observedProperty"];
    [om_observedProperty addAttribute:[GDataXMLNode attributeWithName:@"xlink:href" stringValue:sensor.sensorValue_observable_property]];

    // Feature of interest
    GDataXMLElement * om_featureOfInterest = [GDataXMLNode elementWithName:@"om:featureOfInterest"];
    GDataXMLElement * sa_SamplingPoint = [GDataXMLNode elementWithName:@"sa:SamplingPoint"];
    [sa_SamplingPoint addAttribute:[GDataXMLNode attributeWithName:@"gml:id" stringValue:sensor.FOI]];
    
    GDataXMLElement * gml_name = [GDataXMLNode elementWithName:@"gml:name" stringValue:sensor.FOI_SamplingPoint];
    GDataXMLElement * sa_sampledFeature = [GDataXMLNode elementWithName:@"sa:sampledFeature"];
    GDataXMLElement * sa_position = [GDataXMLNode elementWithName:@"sa:position"];
    
    GDataXMLElement * gml_Point = [GDataXMLNode elementWithName:@"gml:Point"];
    GDataXMLElement * gml_pos = [GDataXMLNode elementWithName:@"gml:pos" stringValue:[sensor getFormattedFOIPosition]];
    [gml_pos addAttribute:[GDataXMLNode attributeWithName:@"srsName" stringValue:@"urn:ogc:def:crs:EPSG::4326"]];
    
    [gml_Point addChild:gml_pos];
    [sa_position addChild:gml_Point];
    
    [sa_SamplingPoint addChild:gml_name];
    [sa_SamplingPoint addChild:sa_sampledFeature];
    [sa_SamplingPoint addChild:sa_position];
    [om_featureOfInterest addChild:sa_SamplingPoint];
    
    // ------
    GDataXMLElement * om_result = [GDataXMLNode elementWithName:@"om:result" stringValue:value];
    [om_result addAttribute:[GDataXMLNode attributeWithName:@"uom" stringValue:sensor.sensorValue_unit_type]];

    [om_Measurement addChild:om_samplingTime];
    [om_Measurement addChild:om_procedure];
    [om_Measurement addChild:om_observedProperty];
    [om_Measurement addChild:om_featureOfInterest];
    [om_Measurement addChild:om_result];

    [insertObservation addChild:assignedSensorId];
    [insertObservation addChild:om_Measurement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:insertObservation];
    NSData *xmlData = document.XMLData;
    
    if (YES) {
        NSString *filePath = [self dataFilePath:TRUE withName:@"InsertObservation" type:@"xml"];
        NSLog(@"Saving xml data to %@...", filePath);
        [xmlData writeToFile:filePath atomically:YES];
    }
    return xmlData;
}

- (NSString*) getFormattedTimeStamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)dataFilePath:(BOOL)forSave withName:(NSString*)fileName type:(NSString*)type{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,type]];
    if (forSave ||
        [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    }
    
}

@end
