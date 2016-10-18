//
//  DateFormat.m
//  Pullup Challenge
//
//  Created by Dayan Yonnatan on 01/06/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "DateFormat.h"

@implementation DateFormat

+(NSArray*)getAvailableDates {
    return [NSArray arrayWithObjects:@"25-03-16",@"25th March 16",@"Friday 25th",@"Friday (25-03-16)",@"Friday 25th March 2016", nil];
}
+(NSString*)dateToString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    return [dateFormatter stringFromDate:date];
}
+(NSDate*)getStartDate:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *newDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",dateString]];
    if(!newDate) {
        NSLog(@"ERROR: Failed to create date!!");
        return nil;
    }
    return newDate;
}
+(NSDate*)getEndDate:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *newDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59",dateString]];
    if(!newDate) {
        NSLog(@"ERROR: Failed to create date!!");
        return nil;
    }
    return newDate;
}
+(NSString *)getSuffixForDate:(NSDate*)theDate
{
    NSDateFormatter *dayOf = [NSDateFormatter new];
    [dayOf setDateFormat:@"dd"];
    
    int number = [[dayOf stringFromDate:theDate] intValue];
    
    NSString *suffix;
    
    int ones = number % 10;
    int tens = (number/10) % 10;
    
    if (tens ==1) {
        suffix = [NSString stringWithFormat:@"th"];
    } else if (ones ==1){
        suffix = [NSString stringWithFormat:@"st"];
    } else if (ones ==2){
        suffix = [NSString stringWithFormat:@"nd"];
    } else if (ones ==3){
        suffix = [NSString stringWithFormat:@"rd"];
    } else {
        suffix = [NSString stringWithFormat:@"th"];
    }
    return suffix;
}

+(NSString*)cleanDigits:(NSString*)string {
    if([[string substringToIndex:1] isEqualToString:@"0"]) {
        return [string substringFromIndex:1];
    } else {
        return string;
    }
}
+(NSString*)getDateStringFromDate:(NSDate*)date {
    return [self getDateStringFromDate:date withIndex:0];
}
+(NSString*)getDateStringFromDate:(NSDate*)date withIndex:(int)index {
    if(index <= 0) {
        // 1. 25-03-16
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"dd-MM-yy"];
        return [formatter stringFromDate:date];
    } else if(index == 1) {
        // 2. 25th March 16
        NSDateFormatter *dayFormat = [NSDateFormatter new];
        NSDateFormatter *restFormat = [NSDateFormatter new];
        [dayFormat setDateFormat:@"dd"];
        [restFormat setDateFormat:@"LLLL yy"];
        
        NSString *string = [NSString stringWithFormat:@"%@%@ %@", [DateFormat cleanDigits:[dayFormat stringFromDate:date]],[self getSuffixForDate:date],[restFormat stringFromDate:date]];
        return string;
    } else if(index == 2) {
        // 3. Friday 25th
        NSDateFormatter *dayFormat = [NSDateFormatter new];
        [dayFormat setDateFormat:@"EEEE"];
        NSDateFormatter *numberFormat = [NSDateFormatter new];
        [numberFormat setDateFormat:@"dd"];
        NSString *string = [NSString stringWithFormat:@"%@ %@%@",[dayFormat stringFromDate:date], [self cleanDigits:[numberFormat stringFromDate:date]], [self getSuffixForDate:date]];
        return string;
    } else if(index == 3) {
        // 4. Friday (25-03-16)
        NSDateFormatter *format = [NSDateFormatter new];
        [format setDateFormat:@"EEEE"];
        NSDateFormatter *basicFormatter = [NSDateFormatter new];
        [basicFormatter setDateFormat:@"dd-MM-yy"];
        NSString *string = [NSString stringWithFormat:@"%@ (%@)", [format stringFromDate:date], [basicFormatter stringFromDate:date]];
        return string;
    } else if(index == 4) {
        // 5. Friday 25th March 2016
        NSDateFormatter *dayOfWkFormat = [NSDateFormatter new];
        [dayOfWkFormat setDateFormat:@"EEEE"];
        NSDateFormatter *dayFormat = [NSDateFormatter new];
        [dayFormat setDateFormat:@"dd"];
        NSDateFormatter *restOfDateFormat = [NSDateFormatter new];
        [restOfDateFormat setDateFormat:@"LLLL yyyy"];
        NSString *string = [NSString stringWithFormat:@"%@ %@%@ %@", [dayOfWkFormat stringFromDate:date], [self cleanDigits:[dayFormat stringFromDate:date]],[self getSuffixForDate:date], [restOfDateFormat stringFromDate:date]];
        return string;
    }
    else {
        NSLog(@"ERROR: No index found!");
        return nil;
    }
}

+(int)getDaysPassed:(NSDate*)dateCreated {
    //NSMutableString *string = [NSMutableString string];
    //NSDate *dateModified = (NSDate*)[workout valueForKey:@"LastModified"];
    
    if(!dateCreated) {
        NSLog(@"ERROR: No date found");
        return 0;
    }
    NSDateFormatter *day = [NSDateFormatter new];
    NSDateFormatter *monthNYear = [NSDateFormatter new];
    [day setDateFormat:@"dd"];
    [monthNYear setDateFormat:@"MM-yy"];
    
    if([[monthNYear stringFromDate:dateCreated] isEqualToString:[monthNYear stringFromDate:[NSDate date]]]) {
        
        int dayIndexToday = [[day stringFromDate:[NSDate date]] intValue];
        int dayIndexCreated = [[day stringFromDate:dateCreated] intValue];
        int daysPassed = dayIndexToday-dayIndexCreated;
        NSLog(@"It was %i days ago", daysPassed);
        return daysPassed;
    }
    else {
        return 0;
    }
    /*
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:dateCreated];
    
    int daysPassed;
    
    if((timePassed/60) > 60) {
        if(((timePassed/60)/60) > 24) {
            [string appendString:[NSString stringWithFormat:@"%.0f days", (((timePassed/60)/60)/24)]];
        } else if((timePassed/60)/60 > 12) {
            daysPassed = 1;
        }
    }
    
    if(string) {
        NSLog(@"Date was modified: %@ ago", string);
        return string;
    }
    return nil;*/
}

@end
