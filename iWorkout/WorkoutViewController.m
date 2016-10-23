//
//  WorkoutViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 10/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "WorkoutViewController.h"
#import "DateFormat.h"
#import "LastModified.h"
#import "Date+CoreDataClass.h"
#import "Exercise+CoreDataClass.h"
#import "ExerciseList+CoreDataClass.h"
#import "ExerciseLister.h"
#import "ExerciseAdder.h"

#define DebugMode 0

@interface WorkoutViewController ()
@end

@implementation WorkoutViewController
{
    CoreDataHelper *cdh;
    
    NSManagedObjectID *objectID;
    Date *dateObject;
    NSArray *arrayOfUnits;
    NSArray *arrayOfWorkouts;
}
@synthesize dateLabel;

#pragma mark - SETUP/LOADING DATA
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.modFormatter = [[NSDateFormatter alloc] init];
    [self.modFormatter setDateFormat:@"HH:mm:ss"];
    
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    
    [self setupData];
    [self createButtonOnNav];
    [self getLastModded];
    [self setDateLabelTextToDaysPassed];
    //[self createToolbar];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    arrayOfWorkouts = [ExerciseLister getArrayOfWorkouts:cdh.context];
    
    [self.navigationController setToolbarHidden:NO];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}
/*
-(void)toolbarUndo {
    NSLog(@"Undo!");
}
-(void)toolbarEdit {
    NSLog(@"Edit!");
}
-(void)createToolbar {
#warning Disabling Toolbar until functionality is available.
 
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(toolbarUndo)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toolbarEdit)];
    
    [self setToolbarItems:@[undoButton, space, edit]];
}*/
-(void)setDateLabelTextToDaysPassed {
    int DaysPassed = [DateFormat getDaysPassed:dateObject.date];
    if(DaysPassed == 0) {
        self.dateLabel.text = @"Today";
    } else if(DaysPassed == 1) {
        self.dateLabel.text = @"Yesterday";
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"%i days ago", DaysPassed];
    }
}
-(void)createButtonOnNav {
    NSDateFormatter *dayOfWeekFormat = [NSDateFormatter new];
    [dayOfWeekFormat setDateFormat:@"EEEE"];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"dd-MM-yy"];
    NSDate *workoutDateNew = dateObject.date;
    
    NSString *navTitle = [NSString stringWithFormat:@"%@ (%@)",[dayOfWeekFormat stringFromDate:workoutDateNew],[dateformatter stringFromDate:workoutDateNew]];
    self.navigationItem.title = navTitle;
    

    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleDone target:self action:@selector(showHelp)];
    
    self.navigationItem.rightBarButtonItem = helpButton;
}
-(void)setupData {
    dateObject = [cdh.context objectWithID:objectID];
    
    arrayOfUnits = [self getArrayOfUnits];
    arrayOfWorkouts = [ExerciseLister getArrayOfWorkouts:cdh.context];
}
-(NSArray*)getArrayOfUnits {
    NSArray *unitArray = [NSArray arrayWithObjects:@"Reps",@"Reps", nil];
    return unitArray;
}
-(void)sendObject:(NSManagedObjectID*)objIn {
    objectID = objIn;
}

#pragma mark - DATE MODIFIED FUNCTIONS
-(void)getLastModded {
    self.lastModifiedLabel.text = [self getModified];
}
-(NSString*)getModified {
    NSString *lastModded = [self.modFormatter stringFromDate:dateObject.lastModified];
    if([lastModded isEqualToString:@""] || !lastModded) {
        return @"Last modified: never modified";
    } else {
        NSString *lastModComparedToNow = [LastModified compareDates:dateObject.lastModified];
        return [NSString stringWithFormat:@"Last modified: %@ (%@ ago)", lastModded, lastModComparedToNow];
    }
}

#pragma mark - ADDING DATA

-(void)requestEntryToAddToExercise:(Exercise*)exercise isDouble:(BOOL)isDouble {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add" message:@"Enter count to add:" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setTextAlignment:NSTextAlignmentCenter];
        if(isDouble) {
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }
        else {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    }];
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *textfieldString = [alertController.textFields.firstObject text];
        
        [alertController.view endEditing:YES];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [self addDataForExercise:exercise withText:textfieldString];
        });
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [alertController addAction:cancel];
    [alertController addAction:add];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)modifiedData {
    dateObject.lastModified = [NSDate date];
    [cdh backgroundSaveContext];
    
    // Change the date of when it was modified on the label
    self.lastModifiedLabel.text = [NSString stringWithFormat:@"Last modified: %@", [self.modFormatter stringFromDate:[NSDate date]]];
    NSLog(@"New modified date: %@", [self.modFormatter stringFromDate:[NSDate date]]);
}
-(void)addDataForExercise:(Exercise*)exercise withText:(NSString*)textfieldData {
    __block NSNumber *countToAdd;
    BOOL isDouble = [exercise.isDouble boolValue];
    
    if(isDouble) {
        double newDouble = [textfieldData doubleValue] + [exercise.count doubleValue];
        countToAdd = [NSNumber numberWithDouble:newDouble];
    } else {
        int newInt = [textfieldData intValue] + [exercise.count intValue];
        countToAdd = [NSNumber numberWithInt:newInt];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addEntry:countToAdd toWorkout:exercise];
    });
}

-(void)addEntry:(NSNumber*)number toWorkout:(Exercise*)exercise {
    [exercise setCount:number];
    
    // New feature:
    [self modifiedData];
    
    [self refreshViews];
}
-(void)refreshViews {
    [cdh backgroundSaveContext];
    [self.tableView reloadData];
}
-(void)showHelp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Help" message:@"Tap an Exercise to add data\nIf you would like to add more Exercises, go to Settings and Add/Edit your Exercises" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSString*)checkAndReplaceUnderscores:(NSString*)string {
    return [string stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}
#pragma mark - TableView Methods
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    int rowNum = (int)indexPath.row;
    BOOL isDouble;
    
    ExerciseList *excList = [[ExerciseLister getArrayOfWorkouts:cdh.context] objectAtIndex:rowNum];
    
    NSString *name = excList.name;
    NSString *exerciseUnit = excList.unit;
    __block Exercise *selectedExercise;
    
    [dateObject.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.name isEqualToString:name]) {
            selectedExercise = obj;
            *stop = YES;
        }
    }];
    if(!selectedExercise) {
        NSLog(@"No workout found!");
        ExerciseAdder *excAdder = [[ExerciseAdder alloc] initWithContext:cdh.context];
        [excAdder findMissingExercisesForObject:dateObject];
        
    } else {
    isDouble = [selectedExercise.isDouble boolValue];
        NSString *displayName = [name stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    if(isDouble) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ = %.1f %@", displayName, [selectedExercise.count doubleValue], exerciseUnit];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ = %i %@", displayName, [selectedExercise.count intValue], exerciseUnit];
    }
    }
    
    return cell;
}
-(void)findMissingExerciseForDate:(Date*)currentObject {
    ExerciseAdder *excAdder = [[ExerciseAdder alloc] initWithContext:cdh.context];
    [excAdder findMissingExercisesForObject:currentObject];
    [self refreshViews];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isDouble;
    ExerciseList *exerciseListObject = [arrayOfWorkouts objectAtIndex:indexPath.row];
    isDouble = [exerciseListObject.isDouble boolValue];
    
    if(DebugMode) {
        NSLog(@"You selected: %@", exerciseListObject.name);
    }

    _selectedIndexPath = indexPath;
 
    NSString *selectedName = exerciseListObject.name;
    __block Exercise *selectedExercise;
    
    [dateObject.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.name isEqualToString:selectedName]) {
            NSLog(@"Found exercise (isDouble: %@)", [obj.isDouble boolValue] ? @"YES" : @"NO");
            selectedExercise = obj;
            *stop = YES;
        }
    }];
    if(!selectedExercise) {
        NSLog(@"ERROR: NO EXERCISE FOUND!");
        [self findMissingExerciseForDate:dateObject];
    }
    [self requestEntryToAddToExercise:selectedExercise isDouble:isDouble];

    [self unSelectRowAtIndexPath:indexPath];
}
-(void)unSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayOfWorkouts.count;
}
#pragma mark - OTHERS
-(BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
