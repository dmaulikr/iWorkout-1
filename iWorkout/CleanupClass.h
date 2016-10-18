//
//  CleanupClass.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 23/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CleanupClass : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

-(instancetype)initWithCoreDataContext:(NSManagedObjectContext*)context;

-(void)removeEmptyDates;

@end
