//
//  ExerciseLister.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 23/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "ExerciseLister.h"
#import "ExerciseList+CoreDataClass.h"


@implementation ExerciseLister


+(NSArray*)getArrayOfWorkouts:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseList"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"Error when fetching array.. %@", error.localizedDescription);
    }
    if(fetchedObjects.count <= 0) {
        NSLog(@"ERROR: No objects found!");
    } else {
        /*
         [fetchedObjects enumerateObjectsUsingBlock:^(ExerciseList  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             //NSLog(@"name: %@ & exercises under it: %@", obj.name, obj.exercise);
             //NSLog(@"Name: %@", obj.name);
         }];*/
    }
    //NSLog(@"Returned %i objects from Exercise List", (int)fetchedObjects.count);
    return fetchedObjects;
}

@end
