//
//  ExerciseList+CoreDataProperties.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ExerciseList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ExerciseList (CoreDataProperties)

+ (NSFetchRequest<ExerciseList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isDouble;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *unit;
@property (nullable, nonatomic, retain) NSSet<Exercise *> *exercise;

@end

@interface ExerciseList (CoreDataGeneratedAccessors)

- (void)addExerciseObject:(Exercise *)value;
- (void)removeExerciseObject:(Exercise *)value;
- (void)addExercise:(NSSet<Exercise *> *)values;
- (void)removeExercise:(NSSet<Exercise *> *)values;

@end

NS_ASSUME_NONNULL_END
