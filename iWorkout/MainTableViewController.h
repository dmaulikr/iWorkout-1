//
//  MainTableViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 06/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MainTableViewController : UITableViewController

// FetchedResultsController
@property (nonatomic, strong) NSFetchedResultsController *frc;
//@property (nonatomic, strong) NSDateFormatter *dateformatter;

@end
