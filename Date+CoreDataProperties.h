//
//  Date+CoreDataProperties.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Date+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Date (CoreDataProperties)

+ (NSFetchRequest<Date *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSDate *lastModified;
@property (nullable, nonatomic, retain) NSSet<Exercise *> *exercise;

@end

@interface Date (CoreDataGeneratedAccessors)

- (void)addExerciseObject:(Exercise *)value;
- (void)removeExerciseObject:(Exercise *)value;
- (void)addExercise:(NSSet<Exercise *> *)values;
- (void)removeExercise:(NSSet<Exercise *> *)values;

@end

NS_ASSUME_NONNULL_END
