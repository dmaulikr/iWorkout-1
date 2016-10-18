//
//  LastModified.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 07/09/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "LastModified.h"

@implementation LastModified


+(NSString*)compareDates:(NSDate*)dateModified {
    NSMutableString *string = [NSMutableString string];
    //NSDate *dateModified = (NSDate*)[workout valueForKey:@"LastModified"];
    
    if(!dateModified) {
            NSLog(@"ERROR: No last modified date found");
        return nil;
    }
    
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:dateModified];
    
    if((timePassed/60) > 60) {
        if(((timePassed/60)/60) > 24) {
            [string appendString:[NSString stringWithFormat:@"%.0f days", (((timePassed/60)/60)/24)]];
        } else {
            [string appendString:[NSString stringWithFormat:@"%.2f hours", (timePassed/60)/60]];
        }
    } else if((timePassed/60) < 1) {
        [string appendString:[NSString stringWithFormat:@"%.0f seconds", timePassed]];
    } else {
        [string appendString:[NSString stringWithFormat:@"%.0f minutes", timePassed/60]];
    }
    
    if(string) {
        NSLog(@"Date was modified: %@ ago", string);
        return string;
    }
    return nil;
}


@end
