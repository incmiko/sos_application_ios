//
//  CSButton.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "CSButton.h"
@import QuartzCore;

@implementation CSButton

- (id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.;
        [self setTitleColor:[UIColor colorWithRed:56./255. green:55./255. blue:222./255. alpha:1.0] forState:UIControlStateNormal];
    }
    return self;
}


@end
