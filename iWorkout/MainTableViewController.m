//
//  MainTableViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 06/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Workout.h"
#import "WorkoutViewController.h"
#import "DateFormat.h"
#import "DateChecker.h"

#define DebugMode 0

@interface MainTableViewController () 
@end

@implementation MainTableViewController
{
    CoreDataHelper *cdh;
    
    // TESTING REFRESH CONTROL
    UIRefreshControl *customRefreshControl;
}


// TESTING REFRESH CONTROL

-(void)addRefreshControl {
    customRefreshControl = [[UIRefreshControl alloc] init];
    
    
    // Unable to set different colour
    [customRefreshControl setTintColor:[UIColor blueColor]];
    
    [customRefreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:customRefreshControl];
}

-(void)startRefresh {
    [customRefreshControl beginRefreshing];
    if(DebugMode) {
        NSLog(@"Refreshing...");
    }
    [self performFetch];
    [self.tableView reloadData];
    if(DebugMode) {
        NSLog(@"Done refreshing");
    }
    [customRefreshControl endRefreshing];
}
-(void)showHelp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Help" message:@"Tap a selected date to add your workouts\nTo refresh the page drag the table downwards\n\nTo restart and set up new workouts, \nOr to change the date style please tap Back and then press the Settings icon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SomethingChanged) name:@"SomethingChanged" object:nil];
    
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleDone target:self action:@selector(showHelp)];
    
    self.navigationItem.rightBarButtonItem = helpButton;
    
    [self configureFetch];
    [self performFetch];
    
    // Check to make sure objects are returned, otherwise create todays entry
    if(self.frc.fetchedObjects.count <= 0) {
        if(DebugMode) {
            NSLog(@"No data found!");
        }
        // Creating today entry
        [self addTodayEntry];
        
        /* ADD TEMPORARY DATA FOR SCREENSHOTS in iTunes Connect
         [self addTempData]; */
        
        // Updating view
        [self refreshDate];
    }
    
    
    // Check to make sure todays entry exists
    if([self hasLatestDateBeenCreated]) {
        if(DebugMode) {
            NSLog(@"Latest entry is todays date, everythings a go.");
        }
    } else {
        if(DebugMode) {
            NSLog(@"Latest entry is not todays date, attempting to add todays date");
        }
        [self addTodayEntry];
        [self performSelector:@selector(delayConfirm) withObject:nil afterDelay:0.1]; // Added short delay to ensure DB has a lil time to load.
    }
    [self addRefreshControl];
}
-(void)configureFetch {
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:NO]];
    
    // Unsure about this...
    [request setFetchBatchSize:15];
    
    // Caching data
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:@"WorkoutData"];
    
    // Don't need to set up delegate as updates made are automatically synced
    //self.frc.delegate = self;
}

-(void)performFetch {
    if(self.frc) {
        [self.frc.managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if(![self.frc performFetch:&error]) {
                if(DebugMode) {
                    NSLog(@"Failed to perform fetch: %@", error);
                }
            } else {
                if(DebugMode) {
                    NSLog(@"Fetch performed successfully!");
                }
            }
            [self.tableView reloadData];
        }];
    } else {
        if(DebugMode) {
            NSLog(@"Failed to fetch, the fetched results controller is nil.");
        }
    }
}
-(BOOL)hasLatestDateBeenCreated {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if([appDelegate checkIfTodayExists]) {
        if(DebugMode) {
            NSLog(@"Smooth sailing.");
        }
        return YES;
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: Today doesnt exist!");
        }
        return NO;
    }
}
-(void)refreshDate {
    [self performFetch];
    [self.tableView reloadData];
}


// Performs a check whether a custom date selection exists
-(BOOL)dateIndexExists {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults valueForKey:@"DateFormatIndex"]) {
        return YES;
    } else {
        return NO;
    }
}
// If a custom date is selected, it's index is then loaded
-(int)getDateIndex {
    if([self dateIndexExists]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //NSLog(@"Dateformatindex is: %i", [[userDefaults valueForKey:@"DateFormatIndex"] intValue]);
        return [[userDefaults valueForKey:@"DateFormatIndex"] intValue];
    } else {
        return 0;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SomethingChanged" object:nil];
}
-(void)SomethingChanged {
    if(DebugMode) {
        NSLog(@"Something changed!");
    }
    [self refreshDate];
}

-(void)delayConfirm {
    // Update view
    [self refreshDate];
    
    if([self hasLatestDateBeenCreated]) {
        if(DebugMode) {
            NSLog(@"Successfully created todays entry!");
        }
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: This is taking longer than usual, re-trying...");
        }
        // Recursively return to this function until DB has loaded, just in case of a slow load. We want to make sure that todays entry gets
        // added regardless of how slow your iPhone is :)
        [self performSelector:@selector(delayConfirm) withObject:nil afterDelay:0.2];
    }
}
-(void)addTodayEntry {
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    [newObject setValue:[NSDate date] forKey:@"Date"];
    [cdh backgroundSaveContext];
    [cdh.context refreshObject:newObject mergeChanges:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TABLE VIEW DATA SOURCE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.frc.fetchedObjects) {
        return [self.frc.fetchedObjects count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(self.frc.fetchedObjects) {
        NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
        NSDate *date = (NSDate*)[object valueForKey:@"Date"];
        
        BOOL isToday = [DateChecker areDatesEqual:date andDate:[NSDate date]];
        
        cell.textLabel.text = [DateFormat getDateStringFromDate:date withIndex:[self getDateIndex]];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        if(isToday) {
            cell.imageView.image = [self getImageForToday:YES];
        } else {
            cell.imageView.image = [self getImageForToday:NO];
        }
        
        // Set background image
        UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;

    }
    return cell;
}

-(UIImage*)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if(rowIndex == 0) {
        // Top row
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if(rowIndex == rowCount - 1) {
        // Bottom row
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        // All other rows inbetween
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    return background;
}

#pragma mark - OTHER
-(UIImage*)getImageForToday:(BOOL)today {
    if(today) {
        return [UIImage imageNamed:@"new_greenbutton.png"];
    } else {
        return [UIImage imageNamed:@"new_redbutton.png"];
    }
}
#warning Complete the sorting by week (This week, last week, 2 weeks ago, etc..)
-(void)getWeekNo:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dateComp = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
    
    if(DebugMode) {
        NSLog(@"Week %i",(int) dateComp);
    }
    
}
#pragma mark - TABLE VIEW DELEGATE

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];

    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    
    // Testing this..
    // WEEK SORTING TEMPORARY DISABLED.
    //[self getWeekNo:(NSDate*)[object valueForKey:@"Date"]];

    
    NSString *dateLabel = [NSString stringWithFormat:@"%@", [DateFormat getDateStringFromDate:[object valueForKey:@"Date"] withIndex:4]];
    
    [workoutVC setDateLabelText:dateLabel];
    
    if([cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:object] error:nil]) {
        [workoutVC sendObject:object.objectID];
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: No ID found for selected object.");
        }
    }
    
    
    [self.navigationController pushViewController:workoutVC animated:YES];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [self confirmThenDeleteForIndex:indexPath onTableview:tableView];
        
    }
}
-(void)confirmThenDeleteForIndex:(NSIndexPath *)indexPath onTableview:(UITableView*)tableView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete entry?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [tableView beginUpdates];
        [cdh.context performBlockAndWait:^{
            [cdh.context deleteObject:[self.frc objectAtIndexPath:indexPath]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        [cdh backgroundSaveContext];
        [self performFetch];
        [tableView endUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        if(DebugMode) {
            NSLog(@"Deleted object");
        }
        //[self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // do nothing.
        if(DebugMode) {
            NSLog(@"Cancelled by user.");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
    

    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}




// Method to add data
/*
-(void)addTempData {
    NSManagedObject *dayOne = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    NSManagedObject *dayTwo = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    NSManagedObject *dayThree = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
 
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
 
    NSDate *dayOneDate = [dateFormatter dateFromString:@"20-06-2016 15:30:00"];
    NSDate *dayTwoDate = [dateFormatter dateFromString:@"19-06-2016 16:30:00"];
    NSDate *dayThreeDate = [dateFormatter dateFromString:@"18-06-2016 17:30:00"];
 
    //dayOne.date = dayOneDate;
    //dayTwo.date = dayTwoDate;
    //dayThree.date = dayThreeDate;
    [dayOne setValue:dayOneDate forKey:@"Date"];
    [dayTwo setValue:dayTwoDate forKey:@"Date"];
    [dayThree setValue:dayThreeDate forKey:@"Date"];
 
    //What other data do I add.....?
     
    dayOne.hours = [NSNumber numberWithDouble:2.0];
    dayTwo.hours = [NSNumber numberWithDouble:4.0];
    dayThree.hours = [NSNumber numberWithDouble:6.0];
 
    
 
 
    [cdh backgroundSaveContext];
}
*/




@end
