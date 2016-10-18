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
#import "Date.h"
#import "ExerciseList.h"
#import "Exercise.h"
#import "SettingsTableViewController.h"
#import "CleanupClass.h"
#import "SetupViewController.h"
#import "ExerciseAdder.h"
#import "ExerciseLister.h"

#define DebugMode 1

@interface MainTableViewController () 
@end

@implementation MainTableViewController
{
    CoreDataHelper *cdh;
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Help" message:@"Tap a selected date to add your workouts\nTo refresh the page drag the table downwards\n\nTo Add or Edit your Exercises, \nOr to change the Date Format please tap Back and then tap the Settings icon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}
-(UIBarButtonItem*)getSettingsIcon {
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    
    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *fontDictionary = @{NSFontAttributeName : customFont};
    [settingsButton setTitleTextAttributes:fontDictionary forState:UIControlStateNormal];
    return settingsButton;
}
-(void)showSettings {
    SettingsTableViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    [self.navigationController pushViewController:settingsView animated:YES];
}
-(void)performCleanup {
    CleanupClass *cleanUp = [[CleanupClass alloc] initWithCoreDataContext:cdh.context];
    [cleanUp removeEmptyDates];
    [self startRefresh];
    
}
-(void)setupView {
    [self setTitle:@"iWorkout"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.03 green:0.24 blue:0.58 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blueColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleDone target:self action:@selector(showHelp)];
    
    self.navigationItem.rightBarButtonItem = helpButton;
    self.navigationItem.leftBarButtonItem = [self getSettingsIcon];
    
    [self addRefreshControl];
}
-(void)checkForNewExercises {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"NewExercises"] != nil) {
        NSLog(@"Found new exercises to add!");
        NSArray *newExercises = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewExercises"];
    
        NSFetchRequest *fetchDates = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
        [fetchDates setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        NSArray *fetchedDates = [cdh.context executeFetchRequest:fetchDates error:nil];
        
    if(fetchedDates > 0) {
        ExerciseAdder *excAdder = [[ExerciseAdder alloc] initWithContext:cdh.context];
        if([excAdder addNewExercisesForArrayOfDates:fetchedDates withNewExercises:newExercises]) {
            NSLog(@"Added new exercises!");
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"NewExercises"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSLog(@"Failed to add new exercises. Refer to Maintableviewcontroller.");
        }
    } else {
        NSLog(@"No dates fetched.");
    }
    }
}
-(void)startSetup {
    // Display setup
    SetupViewController *setupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SetupViewController"];
    
    setupVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:setupVC animated:YES completion:nil];
}
-(BOOL)isFirstSetupIsComplete {
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstSetup"] boolValue]) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];/*
    if(![self isFirstSetupIsComplete]) {
        [self startSetup];
    } else {
    
    [self setupView];
    //[self configureFetch];
    //[self performFetch];
    
        }*/
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(![self isFirstSetupIsComplete]) {
        [self startSetup];
    } else {
        [self configureFetch];
        [self performFetch];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SomethingChanged) name:@"SomethingChanged" object:nil];
    // Check to make sure objects are returned, otherwise create todays entry
    if(self.frc.fetchedObjects.count <= 0) {
        if(DebugMode) {
            NSLog(@"No data found!");
        }
        // Creating today entry
        [self addTodayEntry];
        
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
    
        [self checkForNewExercises];
        [self refreshDate];
        //[self addTempData];
        /*
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self performCleanup];
        });*/
    }
    
}


-(void)configureFetch {
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    //NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    
    
    // Unsure about this...
    [request setFetchBatchSize:15];
    
    // Caching data
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:@"Dates"];
    
    // Don't need to set up delegate as updates made are automatically synced
    // self.frc.delegate = self;
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
    //NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    Date *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
    //[newObject setValue:[NSDate date] forKey:@"Date"];
    [newObject setDate:[NSDate date]];
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
-(NSArray*)getListOfExercises {
    NSFetchRequest *exerciseListFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseList"];
    [exerciseListFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    NSError *excListError;
    
    NSArray *exerciseListRetrieved = [cdh.context executeFetchRequest:exerciseListFetchRequest error:&excListError];
    if(excListError) {
        NSLog(@"Exercise List Fetch) ERROR: %@", excListError.localizedDescription);
        return nil;
    }
    if(exerciseListRetrieved.count <= 0) {
        NSLog(@"ERROR: No list found!");
        return nil;
    }
    return exerciseListRetrieved;
}
#warning Complete the sorting by week (This week, last week, 2 weeks ago, etc..)
-(void)getWeekNo:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dateComp = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
    
    if(DebugMode) {
        NSLog(@"Week %i",(int) dateComp);
    }
}
-(NSPredicate*)getDatePredicateForDate:(NSDate*)date {
    /*
    NSDate *startDate = [[NSDate alloc] init];
    NSDate *endDate = [[NSDate alloc] init];
    */
    NSDate *startDate = [DateFormat getStartDate:[DateFormat dateToString:date]];
    NSDate *endDate = [DateFormat getEndDate:[DateFormat dateToString:date]];

    NSPredicate *predicate = [[NSPredicate alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"(%K > %@) AND (%K < %@)" argumentArray:@[@"date.date",startDate, @"date.date", endDate]];
    return predicate;
}

#pragma mark - TABLE VIEW DELEGATE
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];

    // Testing this..
    // WEEK SORTING TEMPORARY DISABLED.
    //[self getWeekNo:(NSDate*)[object valueForKey:@"Date"]];
    
    
    Date *currentObject = [self.frc objectAtIndexPath:indexPath];
    NSDate *selectedDate = currentObject.date;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date.date" ascending:NO]]];
    [fetchRequest setPredicate:[self getDatePredicateForDate:selectedDate]];
    
    NSError *error;
    NSArray *objectsRetrieved = [cdh.context executeFetchRequest:fetchRequest error:&error];
    
    if(error) {
        NSLog(@"(Exercise Fetch) ERROR: %@", error.localizedDescription);
    }
    
    if(objectsRetrieved.count <= 0) {
        NSLog(@"No objects found.");
        ExerciseAdder *excAdder = [[ExerciseAdder alloc] initWithContext:cdh.context];
        [excAdder addExercisesForObject:currentObject];
        [cdh backgroundSaveContext];
        
    } else if(objectsRetrieved.count != [ExerciseLister getArrayOfWorkouts:cdh.context].count) {
        NSLog(@"Missing exercises...");
        ExerciseAdder *excAdder = [[ExerciseAdder alloc] initWithContext:cdh.context];
        [excAdder findMissingExercisesForObject:currentObject];
        
    }
    
    else {
        NSLog(@"Objects retrieved: %i", (int) objectsRetrieved.count);
       /* for(Exercise *excObj in objectsRetrieved) {
            NSLog(@"Exc name: %@ & Date: %@", excObj.name, excObj.date.date);
        }*/
    }
    
    
    //NSString *dateLabel = [NSString stringWithFormat:@"%@", [DateFormat getDateStringFromDate:currentObject.date withIndex:4]];
    //[workoutVC setDateLabelText:dateLabel];
    NSError *errorForID;
    if([cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:currentObject] error:&errorForID]) {
        [workoutVC sendObject:currentObject.objectID];
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: No ID found for selected object.");
        }
        if(errorForID) {
            NSLog(@"ERROR: %@", errorForID.localizedDescription);
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




// Methods to add temporary data

-(void)addTempData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Date *dayOne = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *dayTwo = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *dayThree = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *dayFour = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *dayFive = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *daySix = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        Date *daySeven = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:cdh.context];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        NSDate *dayOneDate = [dateFormatter dateFromString:@"10-10-2016 15:30:00"];
        NSDate *dayTwoDate = [dateFormatter dateFromString:@"11-10-2016 16:30:00"];
        NSDate *dayThreeDate = [dateFormatter dateFromString:@"12-10-2016 17:30:00"];
        NSDate *dayFourDate = [dateFormatter dateFromString:@"13-10-2016 17:30:00"];
        NSDate *dayFiveDate = [dateFormatter dateFromString:@"14-10-2016 17:30:00"];
        NSDate *daySixDate = [dateFormatter dateFromString:@"15-10-2016 17:30:00"];
        NSDate *daySevenDate = [dateFormatter dateFromString:@"16-10-2016 17:30:00"];
        
        
        dayOne.date = dayOneDate;
        dayTwo.date = dayTwoDate;
        dayThree.date = dayThreeDate;
        dayFour.date = dayFourDate;
        dayFive.date = dayFiveDate;
        daySix.date = daySixDate;
        daySeven.date = daySevenDate;
    });
    
    [cdh backgroundSaveContext];
    NSLog(@"Added temporary data!");
}





@end
