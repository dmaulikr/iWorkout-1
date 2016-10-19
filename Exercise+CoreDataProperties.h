//
//  Exercise+CoreDataProperties.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Exercise+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Exercise (CoreDataProperties)

+ (NSFetchRequest<Exercise *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *count;
@property (nullable, nonatomic, copy) NSNumber *isDouble;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) Date *date;
@property (nullable, nonatomic, retain) ExerciseList *exerciseList;

@end

NS_ASSUME_NONNULL_END
