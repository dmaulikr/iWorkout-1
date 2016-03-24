//
//  AppDelegate.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "AppDelegate.h"

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
        return NSFloatAttributeType;
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
