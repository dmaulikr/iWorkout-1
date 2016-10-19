//
//  ExerciseList+CoreDataProperties.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "ExerciseList+CoreDataProperties.h"

@implementation ExerciseList (CoreDataProperties)

+ (NSFetchRequest<ExerciseList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ExerciseList"];
}

@dynamic isDouble;
@dynamic name;
@dynamic unit;
@dynamic exercise;

@end
