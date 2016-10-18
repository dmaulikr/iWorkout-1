//
//  Date+CoreDataProperties.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 08/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Date.h"

NS_ASSUME_NONNULL_BEGIN

@interface Date (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSDate *lastModified;
@property (nullable, nonatomic, retain) NSSet<Exercise *> *exercise;

@end

@interface Date (CoreDataGeneratedAccessors)

- (void)addExerciseObject:(Exercise *)value;
- (void)removeExerciseObject:(Exercise *)value;
- (void)addExercise:(NSSet<Exercise *> *)values;
- (void)removeExercise:(NSSet<Exercise *> *)values;

@end

NS_ASSUME_NONNULL_END
