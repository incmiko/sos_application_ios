
//
//  BaseViewController.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize screenWidth, screenHeight,sidePadding;

- (id) init{
    
    self = [super init];
    if (self) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        sidePadding = 23.;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        sidePadding = 23.;
        
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        sidePadding = 23.;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:56./255. green:55./255. blue:222./255. alpha:1.0];
    
    // Do any additional setup after loading the view.
}


@end
