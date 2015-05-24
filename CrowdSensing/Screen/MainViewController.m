//
//  MainViewController.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "MainViewController.h"
#import "StartViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

static MainViewController *sharedInstance;

+ (MainViewController *) sharedInstance {
    
    if (!sharedInstance) {
        sharedInstance = [[MainViewController alloc] init];
    }
    
    return sharedInstance;
}

- (void) showAlertWithTitle:(NSString *)title withText:(NSString *)txt{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                              message:txt
                                             delegate:nil
                                    cancelButtonTitle:@"Dismiss"
                                    otherButtonTitles:nil];
    [alertView show];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    StartViewController* nextWindow = [[StartViewController alloc] init];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:nextWindow] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
