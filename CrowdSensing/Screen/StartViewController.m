//
//  StartViewController.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "StartViewController.h"
#import "DataManager.h"
#import "MainViewController.h"
#import "CommunicationManager.h"
#import "SendEventRequest.h"
#import "SOSManager.h"

@interface StartViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation StartViewController{
    
    CSLabel* lblAccelerationValue;
    CSLabel* lblPhonePositionValue;
    CSLabel* lblMagneticHeadingValue;
    
    CSButton* btnRecord;
}

- (id) init{
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    float contentHeight = 50;

    CSLabel* lblProject = [[CSLabel alloc]initWithFrame:CGRectMake(self.sidePadding, contentHeight, self.screenWidth - self.sidePadding*2, 40)];
    lblProject.font = [UIFont fontWithName:lblProject.font.fontName size:30.];
    lblProject.text = @"Crowd sensing";
    [self.view addSubview:lblProject];
    
    contentHeight += lblProject.frame.size.height+5;
    
    CSLabel* lblCrowd = [[CSLabel alloc]initWithFrame:CGRectMake(self.sidePadding, contentHeight, self.screenWidth - self.sidePadding*2, 20)];
    lblCrowd.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblCrowd.text = @"Diplomamunka";
    [self.view addSubview:lblCrowd];
    
    
    contentHeight += lblCrowd.frame.size.height + 70;
    
    CSLabel* lblAcceleration = [[CSLabel alloc]initWithFrame:CGRectMake(self.sidePadding, contentHeight, 100, 20)];
    lblAcceleration.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblAcceleration.text = @"Acceleration: ";
    [self.view addSubview:lblAcceleration];
    
    lblAccelerationValue = [[CSLabel alloc]initWithFrame:CGRectMake(lblAcceleration.frame.origin.x + lblAcceleration.frame.size.width, contentHeight, self.screenWidth - self.sidePadding*2, 20)];
    lblAccelerationValue.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblAccelerationValue.text = @"0.0G";
    [self.view addSubview:lblAccelerationValue];
    
    contentHeight += lblAcceleration.frame.size.height + 5;
    
    CSLabel* lblPhonePosition = [[CSLabel alloc]initWithFrame:CGRectMake(self.sidePadding, contentHeight, 110, 20)];
    lblPhonePosition.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblPhonePosition.text = @"PhonePosition: ";
    [self.view addSubview:lblPhonePosition];
    
    lblPhonePositionValue = [[CSLabel alloc]initWithFrame:CGRectMake(lblPhonePosition.frame.origin.x + lblPhonePosition.frame.size.width, contentHeight, self.screenWidth - self.sidePadding*2, 20)];
    lblPhonePositionValue.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblPhonePositionValue.text = @"Lying";
    [self.view addSubview:lblPhonePositionValue];
    
    contentHeight += lblPhonePosition.frame.size.height + 5;
    
    CSLabel* lblMagneticHeading = [[CSLabel alloc]initWithFrame:CGRectMake(self.sidePadding, contentHeight, 130, 20)];
    lblMagneticHeading.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblMagneticHeading.text = @"Degree to North: ";
    [self.view addSubview:lblMagneticHeading];
    
    lblMagneticHeadingValue = [[CSLabel alloc]initWithFrame:CGRectMake(lblMagneticHeading.frame.origin.x + lblMagneticHeading.frame.size.width, contentHeight, self.screenWidth - self.sidePadding*2, 20)];
    lblMagneticHeadingValue.font = [UIFont fontWithName:lblProject.font.fontName size:16.];
    lblMagneticHeadingValue.text = @"0.0 °";
    [self.view addSubview:lblMagneticHeadingValue];
    
    contentHeight += lblMagneticHeading.frame.size.height + 5;
    
    CSButton* btnCapture = [[CSButton alloc]initWithFrame:CGRectMake(self.sidePadding, self.screenHeight - 20 - 50, self.screenWidth- self.sidePadding*2, 50)];
    [btnCapture setTitle:@"Capture image" forState:UIControlStateNormal];
    [btnCapture addTarget:self action:@selector(btnCapturePressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btnCapture];
    
    btnRecord = [[CSButton alloc]initWithFrame:CGRectMake(self.sidePadding, btnCapture.frame.origin.y - 7 - 50, self.screenWidth- self.sidePadding*2, 50)];
    [btnRecord setTitle:@"Record voice" forState:UIControlStateNormal];
    [btnRecord setTitle:@"Recording... (Stop record)" forState:UIControlStateSelected];
    [btnRecord addTarget:self action:@selector(btnRecordPressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btnRecord];
    
    CSButton* btnSendNot = [[CSButton alloc]initWithFrame:CGRectMake(self.sidePadding, btnRecord.frame.origin.y - 7 - 50, self.screenWidth- self.sidePadding*2, 50)];
    [btnSendNot setTitle:@"Send event" forState:UIControlStateNormal];
//    [btnSendNot addTarget:self action:@selector(btnSendNotPressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btnSendNot];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accelerationChanged) name:NOTIFICATION_ACCELERATION_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phonePositionChanged) name:NOTIFICATION_PHONEPOSITION_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(degreeToNorthChanged) name:NOTIFICATION_DEGREE_TO_NORTH_CHANGED object:nil];

    [[DataManager sharedInstance] updateLocationWithAcceleration:YES withGyroscope:YES];
}


#pragma mark Data Changed methods

- (void) accelerationChanged{
    lblAccelerationValue.text = [NSString stringWithFormat:@"%.2f G",[DataManager sharedInstance].actualData.acceleration];
}

- (void) phonePositionChanged{
    switch ([DataManager sharedInstance].actualData.phonePosition) {
        case PhonePosition_NotSet:
            lblPhonePositionValue.text = @"Unkown";
            break;
        case PhonePosition_Lying:
            lblPhonePositionValue.text = @"Lying";
            break;
        case PhonePosition_Standing:
            lblPhonePositionValue.text = @"Standing";
            break;
        default:
            break;
    }
}

- (void) degreeToNorthChanged{
    lblMagneticHeadingValue.text = [NSString stringWithFormat:@"%.2f °",[DataManager sharedInstance].actualData.magneticHeading];

}

#pragma mark Take picture methods

- (void) btnCapturePressed{
   
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    [self presentViewController:picker animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [[DataManager sharedInstance] uploadImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }];
}



#pragma mark Recording methods

- (void) btnRecordPressed{
    if (btnRecord.selected) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECORDING_STOPPED object:nil];
        [btnRecord setSelected:NO];
        [[DataManager sharedInstance] stopRecord];

    }
    else{
        [btnRecord setSelected:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordEnded) name:NOTIFICATION_RECORDING_STOPPED object:nil];

        [[DataManager sharedInstance] recordVoice];
    }
}
- (void) recordEnded{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECORDING_STOPPED object:nil];
    [btnRecord setSelected:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
