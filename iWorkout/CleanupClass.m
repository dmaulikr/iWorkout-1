//
//  CleanupClass.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 23/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "CleanupClass.h"
//#import "AppDelegate.h"
#import "Date+CoreDataClass.h"
#import "Exercise+CoreDataClass.h"

@implementation CleanupClass

-(instancetype)initWithCoreDataContext:(NSManagedObjectContext *)context {
    if(self = [super init]) {
        self.context = context;
    }
    return self;
}
-(void)removeEmptyDates {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yy"];
    
    NSString *todayDate = [dateFormat stringFromDate:[NSDate date]];
    
    NSError *errorCatcher;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    NSArray *allObjects = [_context executeFetchRequest:fetchRequest error:&errorCatcher];
    
    if(errorCatcher) {
        NSLog(@"ERROR: %@", errorCatcher.localizedDescription);
    } else if(allObjects.count > 0) {
        NSLog(@"Retrieved %i objects.. Beginning clean up.", (int)allObjects.count);
        
        [allObjects enumerateObjectsUsingBlock:^(Date  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([todayDate isEqualToString:[dateFormat stringFromDate:obj.date]]) {
                NSLog(@"Skipped %@ as it's today", todayDate);
            } else {
                //NSLog(@"Date %@ =", [dateFormat stringFromDate:obj.date]);
                if([self hasEmptyData:obj]) {
                    NSLog(@"Date (%@) IS EMPTY", [dateFormat stringFromDate:obj.date]);
                    [_context deleteObject:obj];
                } else {
                    NSLog(@"Is not empty");
                }
                
            }
        }];
        
        
        NSLog(@"Clean up complete.");
    }
}
-(BOOL)hasEmptyData:(Date*)dateObject {
    __block int objCount = 0, nilCount = 0;
    NSLog(@"objCount = %i", objCount);
    
    [dateObject.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL isDouble = [obj.isDouble boolValue];
        NSLog(@"Exercise %@ = %f", obj.name, isDouble ? [obj.count doubleValue] : [obj.count intValue]);
        objCount++;
        if(isDouble) {
            if([obj.count doubleValue] == 0.0) {
                //NSLog(@"EMPTY");
                nilCount++;
            }
        } else {
            if([obj.count intValue] == 0) {
                //NSLog(@"EMPTY");
                nilCount++;
            }
        }
    }];
    NSLog(@"Count (%i) vs nilCount (%i)", objCount, nilCount);
    if(objCount == nilCount) {
        return YES;
    }
    return NO;
}











@end
