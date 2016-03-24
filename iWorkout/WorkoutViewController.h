//
//  WorkoutViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 10/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface WorkoutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *dataDict;

// Global accessor of chosen Workout
@property (nonatomic, strong) NSMutableString *selectedWorkout;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

-(void)setDateLabelText:(NSString*)textIn;
-(void)sendObject:(NSManagedObjectID*)objIn;

@end
