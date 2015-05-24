//
//  DataManager.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "DataManager.h"
#import "SensorManager.h"
#import "CommunicationManager.h"
#import "GPSManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "MainViewController.h"
#import "CommunicationManager.h"

#import "UpdateSensorDataRequest.h"
#import "UploadImageRequest.h"
#import "UploadVoiceRequest.h"

#import "NSData+Base64.h"

#import "SOSManager.h"

#define UPLOAD_SENSOR_DATA_TIME_INTERVAL 10.

@interface DataManager () <AVAudioPlayerDelegate,AVAudioRecorderDelegate,GPSManagerDelegate>

@property GPSManager * gpsManager;

@end

@implementation DataManager{
    AVAudioSession* session;
    AVAudioRecorder *recorder;
    
    NSString *filePath;
    NSTimer* recordingTimer;
    
    NSTimer* uploadSensorDataTimer;
    bool shouldStartSyncornize;
}

@synthesize actualData;

static DataManager *sharedInstance;

+ (DataManager *) sharedInstance {
    
    if (!sharedInstance)
        sharedInstance = [[DataManager alloc] init];
    
    return sharedInstance;
}

- (id) init{
    
    self = [super init];
    if (self) {
        actualData = [[CSData alloc]init];
        [CommunicationManager sharedInstance];
    }
    return self;
}

- (void) updateLocationWithAcceleration:(bool)acc withGyroscope:(bool)gyro{

    if ([[SOSManager sharedInstance] allSensorsRegistered]) {
        
        [[SOSManager sharedInstance] loadSOSSensors];

        shouldStartSyncornize = YES;
        if (!self.gpsManager)
            self.gpsManager = [[GPSManager alloc]init];
        
        self.gpsManager.delegate = self;
        
        [self.gpsManager startLocationTracking];
        [self.gpsManager startHeadingTracking];

        [[SensorManager sharedInstance] startMeasureAccelerationSensors:acc gyroscope:gyro];
        
    }
    else{
        [[SOSManager sharedInstance] registerUnregisteredSensors];
    }

}

- (void) locationUpdated{
    
    [[SOSManager sharedInstance] updateSensorsPosition:actualData.gpsPosition];
    
    if (shouldStartSyncornize) {
        shouldStartSyncornize = NO;
        
        if (uploadSensorDataTimer) {
            [uploadSensorDataTimer invalidate];
            uploadSensorDataTimer = nil;
        }
        
        uploadSensorDataTimer = [NSTimer scheduledTimerWithTimeInterval:UPLOAD_SENSOR_DATA_TIME_INTERVAL target:self selector:@selector(uploadSensorData) userInfo:nil repeats:YES];
    }
}

#pragma mark Upload Manager methods

- (void) uploadSensorData{
    
    dispatch_queue_t myQueue = dispatch_queue_create("RequestQue",NULL);
    dispatch_async(myQueue, ^{
        [[CommunicationManager sharedInstance] syncronizeDataWithType:SensorType_Magnetometer];
        [[CommunicationManager sharedInstance] syncronizeDataWithType:SensorType_Accelerometer];
        [[CommunicationManager sharedInstance] syncronizeDataWithType:SensorType_GYRO];
    });
}


#pragma mark Record Voice Methods

-(void) recordVoice{
    
    if (!session) {
        [self configureAudioSession];
    }
    
    if (recordingTimer) {
        [recordingTimer invalidate];
        recordingTimer = nil;
    }
    
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(stopRecord) userInfo:nil repeats:NO];

    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    [recorder record];
}

-(void) configureAudioSession{
    // Setup audio session
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    filePath =  [[cachePath stringByAppendingPathComponent:@"RecordedVoice.m4a"] copy];
    
    NSURL *outputFileURL = [NSURL fileURLWithPath:filePath];
    
    session = [AVAudioSession sharedInstance];
    
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                TestLog(@"Microphone is enabled..");
            }
            else {
                // Microphone disabled code
                TestLog(@"Microphone is disabled..");
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[MainViewController sharedInstance] showAlertWithTitle:@"Microphone Access Denied" withText:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"];
                    
                });
            }
        }];
    }
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    [recorder record];

}

- (void) stopRecord{
    [recordingTimer invalidate];
    recordingTimer = nil;
    
    [recorder stop];
    [session setActive:NO error:nil];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECORDING_STOPPED object:self userInfo:nil];
}


- (void) uploadImage:(UIImage *)image{
    
}

- (NSString*) getBase64EncodedStringFromData:(NSData*)data{
    
    return [data base64EncodingWithLineLength:0];
}
- (NSString*) getBase64EncodedStringFromImage:(UIImage*)image{
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    return [imageData base64EncodingWithLineLength:0];
}

- (UIImage *)resizeImage:(UIImage*)image{
    
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float scale;
    
    float maxWidthOrHeight = 640.;

    CGSize newSize;
    
    if (imageWidth > imageHeight) {
        scale = maxWidthOrHeight/imageHeight;
        newSize = CGSizeMake(imageWidth*scale,maxWidthOrHeight);
    }
    else{
        scale = maxWidthOrHeight/imageWidth;
        newSize = CGSizeMake(maxWidthOrHeight,imageHeight*scale);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

@end
