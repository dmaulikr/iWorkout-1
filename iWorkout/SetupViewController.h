//
//  SetupViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//


#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface SetupViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *unitTextField;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *defaultUnits;
@property (nonatomic, strong) NSMutableArray *customWorkouts;

// custom
@property (nonatomic, strong) NSMutableArray *customData;

// New
@property (nonatomic, strong) CoreDataHelper *coreDataHelper;
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end
