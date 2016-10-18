//
//  ExerciseAdder.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 24/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Date.h"

@interface ExerciseAdder : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

-(instancetype)initWithContext:(NSManagedObjectContext*)context;
-(void)addExercisesForObject:(Date*)currentObject;
-(void)findMissingExercisesForObject:(Date*)currentObject;
-(BOOL)addNewExercisesForArrayOfDates:(NSArray*)arrayOfDates withNewExercises:(NSArray*)newExercises;

@end
