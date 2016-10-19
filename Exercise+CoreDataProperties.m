//
//  Exercise+CoreDataProperties.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Exercise+CoreDataProperties.h"

@implementation Exercise (CoreDataProperties)

+ (NSFetchRequest<Exercise *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
}

@dynamic count;
@dynamic isDouble;
@dynamic name;
@dynamic date;
@dynamic exerciseList;

@end
