//
//  XMLWriter.h
//  CrowdSensing
//
//  Created by Mike on 2015. 04. 07..
//  Copyright (c) 2015. Magyar Miklós. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSSensor.h"
@class SOSSensor;

@interface XMLWriter : NSObject

+ (XMLWriter *) sharedInstance;
- (NSData*) createSensorXMLData:(SOSSensor*)newSensor writeToFile:(bool)write;

- (NSData*) createInsertXMLData:(SOSSensor*)sensor withValue:(NSString*)value;

@end
