//
//  AppDelegate.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "AppDelegate.h"
#import "DateChecker.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSString *applicationDocDir;
    BOOL autoLockSetting;
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
+(NSArray*)getWorkouts {
    NSMutableArray *workouts = [NSMutableArray new];
    
    NSString *appDocDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [appDocDir stringByAppendingPathComponent:@"Setup.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:setupPath]) {
        /// run these statements
        
        NSArray *setupData = [NSArray arrayWithContentsOfFile:setupPath];
        [setupData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [workouts addObject:[NSString stringWithFormat:@"%@", [obj valueForKey:@"WorkoutName"]]];
        }];
        
    } else {
        NSLog(@"ERROR: Setup file not found.");
        exit(0);
    }
    return [workouts copy];
}
+(NSArray*)getUnits {
    NSMutableArray *units = [NSMutableArray new];
    
    NSString *appDocDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [appDocDir stringByAppendingPathComponent:@"Setup.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:setupPath]) {
        /// run these statements
        
        NSArray *setupData = [NSArray arrayWithContentsOfFile:setupPath];
        [setupData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [units addObject:[NSString stringWithFormat:@"%@", [obj valueForKey:@"UnitOfMeasurement"]]];
        }];
        
    } else {
        NSLog(@"ERROR: Setup file not found.");
        exit(0);
    }
    return [units copy];
}

/*
+(NSArray*)testMethod {
    
     NSString *setupPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Setup.plist"];
    NSMutableArray *newArray = [NSMutableArray array];
    
        NSArray *array = [NSArray arrayWithContentsOfFile:setupPath];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = [obj valueForKey:@"WorkoutName"];
            NSLog(@"(Testmethod) Workout name: %@", name);
            [newArray addObject:name];
        }];
    return (NSArray*)[newArray copy];
}*/
+(NSManagedObjectModel*)getModel {
    if(![self isSetupComplete]) {
        NSLog(@"ERROR! No data found!");
        return nil;
    }
    NSString *applicationDocDir = (NSString*)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [applicationDocDir stringByAppendingPathComponent:@"Setup.plist"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
        
    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
        
    [entity setName:@"Workout"];
    [entity setManagedObjectClassName:@"Workout"];
        
    NSMutableArray *properties = [NSMutableArray new];
    
    NSAttributeDescription *dateAtt = [[NSAttributeDescription alloc] init];
    [dateAtt setName:@"Date"];
    [dateAtt setAttributeType:NSDateAttributeType];
    [dateAtt setOptional:NO];
    [properties addObject:dateAtt];
    
    /* New feature - 'lastModified' attribute */
    NSAttributeDescription *lastMod = [[NSAttributeDescription alloc] init];
    [lastMod setName:@"LastModified"];
    [lastMod setAttributeType:NSDateAttributeType];
    [lastMod setOptional:YES];
    [properties addObject:lastMod];
    
    NSArray *retrievedData = [[NSArray alloc] initWithContentsOfFile:setupPath];
    if(retrievedData) {
        [retrievedData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = [obj valueForKey:@"WorkoutName"];
            NSString *unit = [obj valueForKey:@"UnitOfMeasurement"];
            
            NSAttributeDescription *attribute = [[NSAttributeDescription alloc] init];
            [attribute setName:name];
            [attribute setAttributeType:[self getAttributeType:unit]];
            [attribute setOptional:YES];
            [attribute setDefaultValue:@0];
            [properties addObject:attribute];
            
            
            /* New
            NSAttributeDescription *unitAtt = [[NSAttributeDescription alloc] init];
            [unitAtt setName:@"Unit"];
            [unitAtt setAttributeType:[self getAttributeType:unit]];
            [unitAtt setOptional:YES];
            [properties addObject:unitAtt];
             */
            
        }];
        
    }
    
    [entity setProperties:properties];
   
    [model setEntities:[NSArray arrayWithObject:entity]];
    return model;
    
}
+(NSAttributeType)getAttributeType:(NSString*)infoD {
    if([infoD isEqualToString:@"Reps"]) {
        return NSInteger16AttributeType;
    } else if([infoD isEqualToString:@"Mins"] || [infoD isEqualToString:@"Km"] || [infoD isEqualToString:@"Miles"]) {
        return NSDoubleAttributeType;
        //return NSFloatAttributeType;
    }
    NSLog(@"ERROR!! Unable to match attribute!");
    return NAN;
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

-(void)setAutoLock:(BOOL)lockSet {
    autoLockSetting = lockSet;
    if(lockSet) {
        [self switchLock:YES];
    } else {
        [self switchLock:NO];
    }
}
-(void)switchLock:(BOOL)lockSetting {
    if(lockSetting) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        NSLog(@"Idle timer switched off");
    } else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        NSLog(@"Idle timer returned to natural state.");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(autoLockSetting) {
        [self setAutoLock:YES];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if(autoLockSetting) {
        [self setAutoLock:NO];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //NSLog(@"Read AppDelegate");
    /*
     * Add function that checks latest database entry to ensure that latest date is created.
     */
   
    if([self checkIfTodayExists]) {
        NSLog(@"Today date exists.");
    } else {
        NSLog(@"Today date doesnt exist, creating a new entry");
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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:NO]]];

    NSArray *fetchedObjects = [self.coreDataHelper.context executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects) {
        NSManagedObject *object = (NSManagedObject*)[fetchedObjects lastObject];
        NSDate *fetchedDate = (NSDate*)[object valueForKey:@"Date"];
        
        BOOL isToday = [DateChecker isSameAsToday:fetchedDate];
        
        if(isToday) {
            //NSLog(@"Today entry exists");
            return YES;
        }
        [_coreDataHelper.context refreshObject:object mergeChanges:NO];
    }
    return NO;
}
-(void)addTodayEntry {
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:_coreDataHelper.context];
    [newObject setValue:[NSDate date] forKey:@"Date"];
    [_coreDataHelper backgroundSaveContext];
    [_coreDataHelper.context refreshObject:newObject mergeChanges:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(autoLockSetting) {
        [self switchLock:YES];
        NSLog(@"Idle timer is DISABLED.");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
