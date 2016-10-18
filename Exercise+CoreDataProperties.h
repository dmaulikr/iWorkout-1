//
//  Exercise+CoreDataProperties.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 08/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Exercise.h"

NS_ASSUME_NONNULL_BEGIN

@interface Exercise (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *count;
@property (nullable, nonatomic, retain) NSNumber *isDouble;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Date *date;
@property (nullable, nonatomic, retain) ExerciseList *exercise;

@end

NS_ASSUME_NONNULL_END
