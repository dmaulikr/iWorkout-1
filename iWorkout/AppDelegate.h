//
//  AppDelegate.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Access to CoreDataHelper property
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

-(CoreDataHelper*)cdh;
+(BOOL)isSetupComplete;	
+(NSString*)getPath;

-(BOOL)checkIfTodayExists;
-(void)setAutoLock:(BOOL)lockSet;
+(BOOL)isFirstTimeSetupComplete;

-(NSDictionary*)fetchLastTenExercisesForExerciseName:(NSString*)exerciseName;

@end

