//
//  CommunicationManager.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "CommunicationManager.h"
#import "Reachability.h"
#import "ConnectionException.h"
#import "InvalidSensorException.h"

#import "SOSManager.h"
#import "SOSSensor.h"
#import "GDataXMLNode.h"

#define UNIQUE_DEVICE_ID @"UNIQUE_DEVICE_ID"
#define SOCKET_TIMEOT 10
//#define BACKEND_URL @"http://crowd-sensing.azurewebsites.net/mobileservice.aspx"

#define BACKEND_URL @"http://192.168.1.106:8080/52n-sos-webapp/sos"
//#define BACKEND_URL @"http://"


@interface CommunicationManager ()

@property (nonatomic, retain) NSString *backendUrl;
@property (nonatomic, retain) NSString *deviceID;

@end

@implementation CommunicationManager{
    int requestCounter;
}

@synthesize backendUrl, deviceID;

static CommunicationManager *sharedInstance;

+ (CommunicationManager *) sharedInstance {
    
    if (!sharedInstance)
        sharedInstance = [[CommunicationManager alloc] init];
    
    return sharedInstance;
}

+ (NSString *) dateToString: (NSDate *) date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate: date];
}

+ (NSDate *) stringToDate: (NSString *) text {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    return [formatter dateFromString: text];
}

#pragma mark - instance methods

- (id) init {
    
    self = [super init];
    
    if (self) {
        
        backendUrl = BACKEND_URL;
        [self readDeviceID];
        if (!deviceID) {
            CFUUIDRef theUUID = CFUUIDCreate(NULL);
            CFStringRef string = CFUUIDCreateString(NULL, theUUID);
            deviceID = (__bridge NSString*)string;
            TestLog(@"unique deviceID: %@", deviceID);
            [self storeDeviceID];
        }
        requestCounter = 0;
    }
    
    return self;
}

- (void) storeDeviceID {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setValue:deviceID forKey: UNIQUE_DEVICE_ID];
    [defaults synchronize];
}

- (void) readDeviceID {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    deviceID = [[NSUserDefaults standardUserDefaults] objectForKey: UNIQUE_DEVICE_ID];
    [defaults synchronize];
}

- (NSString*) getDeviceID{
    return deviceID;
}

- (void) registerSensor:(SOSSensor *)sensor withDelegate:(id<CommunicationManagerDelegate>)delegate{
    
    @try {
        
        NSData *reqData = [sensor getXMLDataWithWriteToFile:YES];
        
        [self postRequest: reqData toUrl:backendUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(registrationWasSuccessful:)])
                [delegate registrationWasSuccessful:sensor];
        });
        
    }
    @catch (MobileServiceException *exception) {

        [exception logError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(registrationFailed:withException:)])
                [delegate registrationFailed:sensor withException:exception];
        });
    }
    @catch (NSException* exception){
        
    }
}

- (void) syncronizeDataWithType:(SensorType)type{
    
    @try {
        
        SOSSensor* sensor = [[SOSManager sharedInstance] findSOSSensorForType:type];
        if (!sensor) {
            InvalidSensorException *ex = [[InvalidSensorException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_Invalid_SOSSensor userMessage:@"Unknown error occured" technicalMessage:@"No sensor found for syncronizeData"]];
            @throw ex;
        }
        NSData *reqData = [sensor getInsertData];
        
       [self postRequest: reqData toUrl:backendUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{

        });
        
    }
    @catch (MobileServiceException *exception) {
        [exception logError];
        
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }
}


- (NSData *) postRequest: (NSData *) body toUrl: (NSString *) absoluteUrl {
        
    if (body == nil || [body length] == 0) {
        
        MobileServiceException *ex = [[MobileServiceException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_Invalid_Request userMessage:@"Unkown error occured" technicalMessage:@"Invalid request body: body must be set."]];
        @throw ex;
    }
    
    TestLog(@"Url: %@", absoluteUrl);
    
    NSURL *url = [NSURL URLWithString: absoluteUrl];
    
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error: &error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: SOCKET_TIMEOT];
    
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[body length]] forHTTPHeaderField: @"Content-Length"];
    
    [request setHTTPBody: body];
    
    NSHTTPURLResponse *response = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
    
    if (!responseData || (response.statusCode != 200)) {
        
        if ([self getNetworkStatus] == NotReachable) {
            
            ConnectionException *ex = [[ConnectionException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_No_Internet_Connection userMessage:@"No internet connection." technicalMessage:@"No internet connection."]];
            @throw ex;
        }
        else {
            ConnectionException *ex = [[ConnectionException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_Invalid_Response userMessage:@"Unable to reach server. Please check the internet connection and try it again later." technicalMessage:@"Unable to reach server. Please check the internet connection and try it again later."]];
            @throw ex;
        }
    }
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData options:0 error:&error];
    NSLog(@"######### RESPONSE: %@", doc.rootElement);
    NSArray* exceptions = [doc.rootElement elementsForName:@"ows:Exception"];
    if (!doc) {
        MobileServiceException *ex = [[MobileServiceException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_Invalid_Response userMessage:@"Unkown error occured" technicalMessage:@"Invalid response body: empty response"]];
        @throw ex;
    }
    else if (exceptions.count > 0){
        GDataXMLElement *exception = (GDataXMLElement *) [exceptions objectAtIndex:0];
        GDataXMLNode* attribute = [exception attributeForName:@"exceptionCode"];
        NSString* errorType = [attribute stringValue];
        
        NSString* errorMessage = @"Unknown exception";
        NSArray* exceptionText = [exception elementsForName:@"ows:ExceptionText"];
        if (exceptionText.count > 0) {
            GDataXMLElement *exT = (GDataXMLElement *) [exceptions objectAtIndex:0];
            errorMessage = [exT stringValue];
        }
        MobileServiceException *ex = [[MobileServiceException alloc] initWithServiceError:[[ServiceError alloc]initWithErrorCode:ErrorCode_Response_Exception userMessage:@"An error occured" technicalMessage:[NSString stringWithFormat:@"Exception raised: %@ - details: %@",errorType,errorMessage]]];
        @throw ex;
    }
    
    return responseData;
}

- (NetworkStatus) getNetworkStatus {
    
    return  [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
}

@end
