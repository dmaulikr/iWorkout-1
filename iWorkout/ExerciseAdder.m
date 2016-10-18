//
//  ExerciseAdder.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 24/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "ExerciseAdder.h"
#import "ExerciseList.h"
#import "ExerciseLister.h"
#import "Exercise.h"

@implementation ExerciseAdder

-(instancetype)initWithContext:(NSManagedObjectContext*)context {
    if(self = [super init]) {
        self.context = context;
    }
    return self;
}

-(void)addExercisesForObject:(Date*)currentObject {
    NSArray *exerciseList = [ExerciseLister getArrayOfWorkouts:self.context];
    NSMutableArray *newEntries = [[NSMutableArray alloc] init];
    for(ExerciseList *exerciseFromList in exerciseList) {
        Exercise *newExercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:self.context];
        [newExercise setName:exerciseFromList.name];
        [newExercise setDate:currentObject];
        [newExercise setIsDouble:exerciseFromList.isDouble];
        NSLog(@"Added %@", exerciseFromList.name);
        [newEntries addObject:newExercise];
    }
    [currentObject.exercise setByAddingObjectsFromArray:newEntries];
    NSLog(@"Added exercises!");
    NSError *error;
    if(![self.context save:&error]) {
        NSLog(@"ERROR while Saving: %@", error.localizedDescription);
    }
}
-(void)addMissingExercisesForObject:(Date*)dateObject withName:(NSString*)name isDouble:(BOOL)isDouble {
    Exercise *newExercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:self.context];
    [newExercise setName:name];
    [newExercise setIsDouble:[NSNumber numberWithBool:isDouble]];
    [newExercise setDate:dateObject];
    [dateObject.exercise setByAddingObject:newExercise];
    NSError *error;
    if(![self.context save:&error]) {
        NSLog(@"ERROR while Saving: %@", error.localizedDescription);
    }
}
-(void)findMissingExercisesForObject:(Date*)currentObject {
    NSArray *exerciseList = [ExerciseLister getArrayOfWorkouts:self.context];
    
    NSMutableArray *missingExercises = [[NSMutableArray alloc] init];
    [exerciseList enumerateObjectsUsingBlock:^(ExerciseList  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [missingExercises addObject:obj.name];
    }];
    
    NSMutableArray *currentExercises = [[NSMutableArray alloc] init];
    [currentObject.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
        [currentExercises addObject:obj.name];
    }];
    [currentExercises enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([missingExercises containsObject:obj]) {
            [missingExercises removeObject:obj];
        }
    }];
    NSLog(@"The missing exercises are: ");
    [missingExercises enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL foundObject = false;
        __block BOOL isDouble;
        [exerciseList enumerateObjectsUsingBlock:^(ExerciseList  *_Nonnull excObj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([excObj.name isEqualToString:obj]) {
                isDouble = [excObj.isDouble boolValue];
                foundObject = true;
                *stop = TRUE;
            }
        }];
        
        NSLog(@"%@ isBool: %@",obj, isDouble ? @"YES" : @"NO");
        [self addMissingExercisesForObject:currentObject withName:obj isDouble:isDouble];
    }];
}
-(BOOL)addNewExercisesForArrayOfDates:(NSArray*)arrayOfDates withNewExercises:(NSArray*)newExercises {
    [arrayOfDates enumerateObjectsUsingBlock:^(Date * _Nonnull dateObj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [newExercises enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:self.context];
            [exercise setName:[obj valueForKey:@"Name"]];
            [exercise setIsDouble:(NSNumber*)[obj objectForKey:@"IsDouble"]];
            [exercise setDate:dateObj];
            
            [dateObj.exercise setByAddingObject:exercise];
            NSLog(@"Added %@ & isDouble: %@", exercise.name, [[obj objectForKey:@"IsDouble"] boolValue] ? @"TRUE" : @"FALSE");
        }];
        
    }];
    if([self.context save:nil]) {
        return YES;
    } else {
        return NO;
    }
    
}




@end
