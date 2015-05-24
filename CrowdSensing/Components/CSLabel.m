//
//  CSLabel.m
//  CrowdSensing
//
//  Created by Mike on 2014. 11. 23..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "CSLabel.h"

@implementation CSLabel

- (id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
