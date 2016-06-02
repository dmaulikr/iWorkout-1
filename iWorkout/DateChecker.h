//
//  DateChecker.h
//  Pullup Challenge
//
//  Created by Dayan Yonnatan on 01/06/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateChecker : NSObject

+(BOOL)isSameAsToday:(NSDate*)date;
+(BOOL)areDatesEqual:(NSDate*)firstDate andDate:(NSDate*)secondDate;

@end
