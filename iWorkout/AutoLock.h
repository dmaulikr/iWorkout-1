//
//  AutoLock.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 05/01/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoLock : NSObject

+(void)preventAutoLock:(BOOL)lockSetting;
+(BOOL)getStatus;
+(void)writeUserDefaults:(BOOL)status;
+(BOOL)readUserDefaults;
+(void)temporarySwitchOff;
+(void)switchOn;


@end
