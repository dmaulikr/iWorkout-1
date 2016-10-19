//
//  Date+CoreDataProperties.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 19/10/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Date+CoreDataProperties.h"

@implementation Date (CoreDataProperties)

+ (NSFetchRequest<Date *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Date"];
}

@dynamic date;
@dynamic lastModified;
@dynamic exercise;

@end
