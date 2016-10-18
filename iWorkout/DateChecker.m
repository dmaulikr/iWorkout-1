//
//  DateChecker.m
//  Pullup Challenge
//
//  Created by Dayan Yonnatan on 01/06/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "DateChecker.h"

@implementation DateChecker

+(BOOL)isSameAsToday:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yy"];
    
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *otherDateString = [dateFormatter stringFromDate:date];
    
    if([todayString compare:otherDateString] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

+(BOOL)areDatesEqual:(NSDate*)firstDate andDate:(NSDate*)secondDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yy"];
    
    NSString *firstDateString = [dateFormatter stringFromDate:firstDate];
    NSString *secondDateString = [dateFormatter stringFromDate:secondDate];
    
    if([firstDateString compare:secondDateString] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

@end
