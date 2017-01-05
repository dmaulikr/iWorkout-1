//
//  AppDelegate.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "AppDelegate.h"
#import "DateChecker.h"
#import "Date+CoreDataClass.h"
#import "Exercise+CoreDataClass.h"
#import "DateFormat.h"
#import "AutoLock.h"

#define DebugMode 1

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSString *applicationDocDir;
}


+(NSString*)getPath {
    NSString *applicationDocDir = (NSString*)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [applicationDocDir stringByAppendingPathComponent:@"Setup.plist"];
    
    return setupPath;
    
}
-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
-(CoreDataHelper *)cdh {
    if(!_coreDataHelper) {
        static dispatch_once_t predicate;
        
        dispatch_once(&predicate, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

+(BOOL)isSetupComplete {
    // Check if MODEL data exists, if yes: return yes
    // else return NO
    NSString *applicationDocDir = (NSString*)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [applicationDocDir stringByAppendingPathComponent:@"Setup.plist"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"SetupComplete"] boolValue]) {
        if([[NSFileManager defaultManager] fileExistsAtPath:setupPath]) {
            return YES;
        }
    }
    return NO;
}
+(BOOL)isFirstTimeSetupComplete {
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstSetup"] boolValue]) {
        return YES;
    }
    return NO;
}

-(NSDictionary*)fetchLastTenExercisesForExerciseName:(NSString*)exerciseName {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    [fetchRequest setFetchLimit:10];
    
    NSError *error;
    
    NSArray *fetchedObjects = [self.cdh.context executeFetchRequest:fetchRequest error:&error];
    
    if(!fetchedObjects) {
        NSLog(@"Error: No fetched objects");
        return (NSDictionary*)nil;
    }
    if(error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return (NSDictionary*)nil;
    }
    
    for(Date *object in fetchedObjects) {
        [object.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
            if([exerciseName isEqualToString:obj.name]) {
                NSString *stringOfDate = [DateFormat dateToString:object.date];
                NSLog(@"%@: %@", stringOfDate, obj.count);
                
                [mutableDictionary setValue:obj.count forKey:stringOfDate];
            }
        }];
    }
    return [mutableDictionary copy];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if([AutoLock readUserDefaults]) {
        [AutoLock preventAutoLock:true];
    }
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if([AutoLock getStatus]) {
        [AutoLock temporarySwitchOff];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if([AutoLock getStatus]) {
        [AutoLock temporarySwitchOff];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //NSLog(@"Read AppDelegate");
    /*
     * Add function that checks latest database entry to ensure that latest date is created.
     */
    if([AutoLock readUserDefaults]) {
        [AutoLock switchOn];
    }
   
    if([self checkIfTodayExists]) {
        if(DebugMode) {
            NSLog(@"Today date exists.");
        }
    } else {
        if(DebugMode) {
            NSLog(@"Today date doesnt exist, creating a new entry");
        }
        if(_coreDataHelper.context) {
        [self addTodayEntry];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
        } else {
            //NSLog(@"ERROR: Context doesn't exist, check App Delegate.");
        }
    }
}

-(BOOL)checkIfTodayExists {
    NSError *error;
    //NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];

    NSArray *fetchedObjects = [self.coreDataHelper.context executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects) {
        Date *fetchedObject = [fetchedObjects lastObject];
        
        BOOL isToday = [DateChecker isSameAsToday:fetchedObject.date];
        NSLog(@"Does todays date exist? %@", isToday ? @"YES" : @"NO");
        
        if(isToday) {
            return YES;
        }
        [_coreDataHelper.context refreshObject:fetchedObject mergeChanges:NO];
    }
    return NO;
}
-(void)addTodayEntry {
    Date *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:_coreDataHelper.context];
    [newObject setDate:[NSDate date]];
    NSLog(@"Added %@ as a new date object.", [NSDate date]);
    [_coreDataHelper backgroundSaveContext];
    [_coreDataHelper.context refreshObject:newObject mergeChanges:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([AutoLock readUserDefaults]) {
        [AutoLock preventAutoLock:true];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
