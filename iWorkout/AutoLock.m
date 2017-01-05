//
//  AutoLock.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 05/01/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

#import "AutoLock.h"
#import "AppDelegate.h"

@implementation AutoLock


/*
 -(void)switchLock:(BOOL)lockSetting {
 if(lockSetting) {
 [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
 if(DebugMode) {
 NSLog(@"Idle timer DISABLED to prevent iPhone from locking.");
 }
 } else {
 [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
 if(DebugMode) {
 NSLog(@"Idle timer returned to natural state.");
 }
 }
 }
 */

+(void)preventAutoLock:(BOOL)lockSetting {
    [[UIApplication sharedApplication] setIdleTimerDisabled:lockSetting];
    [self writeUserDefaults:lockSetting];
}
+(void)temporarySwitchOff {
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
}
+(void)switchOn {
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
}
+(BOOL)getStatus {
    return [UIApplication sharedApplication].isIdleTimerDisabled;
}
+(void)writeUserDefaults:(BOOL)status {
    NSNumber *statusObject;
    if(status) {
        statusObject = [[NSNumber alloc] initWithInt:1];
    } else {
        statusObject = [[NSNumber alloc] initWithInt:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:statusObject forKey:@"PreventAutoLock"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Written %@ to PreventAutoLock", [statusObject intValue] == 1 ? @"true" : @"false");
}
+(BOOL)readUserDefaults {
    int status = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PreventAutoLock"] intValue];
    NSNumber *statusObject = [[NSNumber alloc] initWithInt:status];
    
    if([statusObject intValue] == 1) {
        NSLog(@"Prevent auto lock is ON");
        return true;
    } else {
        NSLog(@"Prevent auto lock is OFF");
        return false;
    }
}




@end
