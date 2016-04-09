//
//  ThumbnailCreator.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 25/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "ThumbnailCreator.h"


@implementation ThumbnailCreator


+(UIImage*)createThumbnailWithImage:(UIImage*)image {
    NSData *imageData = UIImagePNGRepresentation(image);
 
    UIImage *newImage = [UIImage imageWithData:imageData];
    CGSize size = CGSizeMake(25, 25);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
   // return UIImagePNGRepresentation(thumbnail); - Returns NSData
    return thumbnail;
}
@end
