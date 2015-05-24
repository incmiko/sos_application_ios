//
//  BackgroundTaskManager.m
//  CrowdSensing
//
//  Created by Mike on 2014. 12. 16..
//  Copyright (c) 2014. Magyar Miklós. All rights reserved.
//

#import "BackgroundTaskManager.h"

@interface BackgroundTaskManager()

@property (nonatomic, strong)NSMutableArray* bgTaskIdList;
@property (assign) UIBackgroundTaskIdentifier masterTaskId;

@end

@implementation BackgroundTaskManager

@synthesize bgTaskIdList,masterTaskId;

+(instancetype)sharedBackgroundTaskManager{
    static BackgroundTaskManager* sharedBGTaskManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBGTaskManager = [[BackgroundTaskManager alloc] init];
    });
    
    return sharedBGTaskManager;
}

-(id)init{
    self = [super init];
    if(self){
        bgTaskIdList = [NSMutableArray array];
        masterTaskId = UIBackgroundTaskInvalid;
    }
    
    return self;
}

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask
{
    UIApplication* application = [UIApplication sharedApplication];
    
    UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]){
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            // backgorund task expired
        }];
        if (masterTaskId == UIBackgroundTaskInvalid )
        {
            masterTaskId = bgTaskId;
            // master task started
        }
        else
        {
            //background task started
            [bgTaskIdList addObject:@(bgTaskId)];
            [self endBackgroundTasks];
        }
    }
    
    return bgTaskId;
}

-(void)endBackgroundTasks
{
    [self drainBGTaskList:NO];
}

-(void)endAllBackgroundTasks
{
    [self drainBGTaskList:YES];
}

-(void)drainBGTaskList:(BOOL)all
{
    UIApplication* application = [UIApplication sharedApplication];
    if([application respondsToSelector:@selector(endBackgroundTask:)]){
        NSUInteger count = bgTaskIdList.count;
        for ( NSUInteger i = (all ? 0 : 1); i<count; i++ )
        {
            // background task is ended
            UIBackgroundTaskIdentifier bgTaskId = [[bgTaskIdList objectAtIndex:0] integerValue];
            [application endBackgroundTask:bgTaskId];
            [bgTaskIdList removeObjectAtIndex:0];
        }
        if (bgTaskIdList.count > 0)
        {
            // background task is still alive
        }
        if ( all )
        {
            // there is no more background tasks which is running
            [application endBackgroundTask:masterTaskId];
            masterTaskId = UIBackgroundTaskInvalid;
        }
        else
        {
            // master background task
        }
    }
}


@end
