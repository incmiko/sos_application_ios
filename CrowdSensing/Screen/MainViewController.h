//
//  MainViewController.h
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "BaseViewController.h"

@interface MainViewController : BaseViewController

+ (MainViewController *) sharedInstance;

- (void) showAlertWithTitle:(NSString*)title withText:(NSString*)txt;

@end
