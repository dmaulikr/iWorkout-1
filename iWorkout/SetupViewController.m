//
//  SetupViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "SetupViewController.h"
#import "AppDelegate.h"
#import "ExerciseList+CoreDataClass.h"
#import "Date+CoreDataClass.h"
#import "Exercise+CoreDataClass.h"

#define DebugMode 0

@interface SetupViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@end

//NSString * const customName = @"Create custom...";

@implementation SetupViewController
{
    BOOL firstSetupExists;
    NSMutableArray *newExercises;
    UITextField *unitTextFieldHolder;
}

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.coreDataHelper = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    
    // Set up the default array of units and customWorkouts
    self.defaultUnits = [[NSMutableArray alloc] initWithObjects:@"Choose from below..",@"Reps",@"Km",@"Miles",@"Mins", nil];
    
    NSFetchRequest *exerciseList = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseList"];
    [exerciseList setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:exerciseList managedObjectContext:self.coreDataHelper.context sectionNameKeyPath:nil cacheName:nil];
    [self performFetch];
    
    //self.customWorkouts = [[NSMutableArray alloc] init];
    
    // Custom dictionary
    //self.customData = [[NSMutableArray alloc] init];
    
    // Set up the unit pickerView
    //self.unitPicker.delegate = self;
    //self.unitPicker.dataSource = self;
    
    //[self.unitPicker reloadAllComponents];
    
    // Set up table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    
    self.unitTextField.delegate = self;
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstSetup"] boolValue]) {
        firstSetupExists = YES;
        NSLog(@"Edit exercise mode entered.");
        newExercises = [[NSMutableArray alloc] init];
        [self reloadView];
    } else {
        firstSetupExists = NO;
        NSLog(@"This is first time set up.");
    }
    
    // Switch off Autocorrect
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
}
-(void)viewDidAppear:(BOOL)animated {
    if(!firstSetupExists) {
        [self displayFirstTimeWelcome];
    }
}

-(void)displayFirstTimeWelcome {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Welcome to iWorkout" message:@"Please enter the exercises you would like to track,\nDon't worry, you can always change them later" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok, thanks!" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:ok];
    [self presentViewController:alertC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Unit of Measurement selection
-(void)displayUnitOfMeasurementSelection {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Unit of Measurement" message:@"Select how you want to track this exercise (e.g. KM/Miles/Repetitions)" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setInputView:pickerView];
        unitTextFieldHolder = textField;
        [textField setTextAlignment:NSTextAlignmentCenter];
    }];
    UIAlertAction *select = [UIAlertAction actionWithTitle:@"Select" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.unitTextField setText:unitTextFieldHolder.text];
        unitTextFieldHolder = nil;
    }];
    [alert addAction:select];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ACTIONS
-(IBAction)help:(id)sender {
    UIAlertController *helpController = [UIAlertController alertControllerWithTitle:@"Instructions of use" message:@"Please enter a exercise name and a unit of measurement to match, and continue doing so until you have all your exercises listed below.\n\ne.g. Exercise name: Pushups\nUnit of measurement: Reps\n\n Exercise name: Cycling\nUnit of measurement: Km" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                       //nil
                                                    }];
    [helpController addAction:dismiss];
    [self presentViewController:helpController animated:YES completion:nil];
    
}

-(IBAction)done:(id)sender {
    if(self.frc.fetchedObjects.count <= 0) {
        [self displayErrorAlertWithTitle:@"Error: No entries added" andMessage:@"No exercises have been added.\nTap 'Help' on the top-left for more help."];
    } else {
        [self.coreDataHelper backgroundSaveContext];

    if(!firstSetupExists) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"FirstSetup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"First time set up complete.");
    } else {
        if(newExercises.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:newExercises forKey:@"NewExercises"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSLog(@"No new exercises added.");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)displayErrorAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)addWorkout:(id)sender {
    if(!self.textField.text || [self.textField.text isEqualToString:@""]) {
        [self displayErrorAlertWithTitle:@"Empty Exercise Name" andMessage:@"Please enter a exercise name"];
        return;
    }
    if(!self.unitTextField.text || [self.unitTextField.text isEqualToString:@""]) {
        [self displayErrorAlertWithTitle:@"Unit not selected" andMessage:@"Please select a unit to match your exercise"];
        return;
    }
    if(![self isValidStringLength:self.textField.text]) {
        [self displayErrorAlertWithTitle:@"Invalid String Length" andMessage:@"Please keep the workout name below 30 characters."];
        return;
    }

    NSString *exerciseName = [self replaceSpacesWithUnderscores:[self changeFirstLetterToUppercase:self.textField.text]];
    if([self doesExerciseExist:exerciseName]) {
        [self displayErrorAlertWithTitle:@"Exercise Already Exists" andMessage:@"The exercise you entered already exists."];
    } else {
        [self addExerciseWithName:exerciseName];
    }
}

-(NSString*)changeFirstLetterToUppercase:(NSString*)receivedString {
    BOOL isLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[receivedString characterAtIndex:0]];
    if(isLowercase) {
        NSString *firstLetter = [NSString stringWithFormat:@"%c",[receivedString characterAtIndex:0]];
        NSString *upperCaseString = [firstLetter uppercaseString];
        NSString *newString = [receivedString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:upperCaseString];
            return newString;
        } else {
            return receivedString;
        }
}
-(NSString*)replaceSpacesWithUnderscores:(NSString*)string {
    // Replacing all occurences of spaces ' ' with underscores '_'
    NSString *newString = [NSString stringWithFormat:@"%@", [string stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    return newString;
}

-(void)addExerciseWithName:(NSString*)name {
    [self.textField resignFirstResponder];
    if([self isValidString:name]) {
        NSString *unit = [self.unitTextField text];
        if([unit isEqualToString:@"Reps"]) {
            [self addExerciseWithName:name andUnit:unit isDouble:NO];
        } else {
            [self addExerciseWithName:name andUnit:unit isDouble:YES];
        }
    } else {
        [self displayErrorAlertWithTitle:@"Invalid Characters" andMessage:[NSString stringWithFormat:@"The name '%@' contains illegal characters. No symbols please", name]];
    }
    [self reloadView];
    self.textField.text = @"";
    self.unitTextField.text = @"";
}
-(void)reloadView {
    [self performFetch];
    [self.tableView reloadData];
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
-(BOOL)doesExerciseExist:(NSString*)name {
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseList"];
    __block BOOL doesExerciseExist = NO;
    [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    self.coreDataHelper = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    
    NSArray *fetchedObjects = [self.coreDataHelper.context executeFetchRequest:fetch error:nil];
    
    [fetchedObjects enumerateObjectsUsingBlock:^(ExerciseList  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Exercise Name: %@", obj.name);
        if([obj.name isEqualToString:name]) {
            doesExerciseExist = YES;
            *stop = YES;
        }
    }];
    return doesExerciseExist;
}
-(void)addExerciseWithName:(NSString*)name andUnit:(NSString*)excUnit isDouble:(BOOL)isDouble {
    ExerciseList *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseList" inManagedObjectContext:self.coreDataHelper.context];
    
    exercise.name = name;
    exercise.isDouble = [NSNumber numberWithBool:isDouble];
    exercise.unit = [NSString stringWithFormat:@"%@",excUnit];

    [self.coreDataHelper backgroundSaveContext];
    if(firstSetupExists) {
        // This means we're in editing mode.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:name forKey:@"Name"];
        [dict setObject:[NSNumber numberWithBool:isDouble] forKey:@"IsDouble"];
        [newExercises addObject:dict];
    }
}

#pragma mark - SAFE CHECKS
-(BOOL)entryAlreadyExists:(NSString*)entry {
    __block int exists = 0;
   [self.customData enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       NSString *name = [obj valueForKey:@"WorkoutName"];
        if([name isEqualToString:entry]) {
            exists = 1;
            *stop = YES;
        }
    }];
    return exists ? YES : NO;
}
#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self displayUnitOfMeasurementSelection];
}

#pragma mark - FetchedResultsController Delegate Methods
- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            NSLog(@"Deleting object thru FRC.");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableView beginUpdates];
}

#pragma mark - TABLEVIEW DATASOURCE
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.frc.fetchedObjects.count;
}
#pragma mark - TABLEVIEW DELEGATE
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        //[self.customData removeObjectAtIndex:indexPath.row];
        NSString *objectName;
        ExerciseList *exercise = [self.frc objectAtIndexPath:indexPath];
        objectName = [NSString stringWithFormat:@"%@", exercise.name];
        [exercise.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.coreDataHelper.context deleteObject:obj];
        }];
        [self removeExerciseFromDatesUsingName:objectName];
        
        [self.coreDataHelper.context deleteObject:exercise];
        [self.coreDataHelper backgroundSaveContext];
        NSLog(@"Deleted %@", objectName);
        
        [self.coreDataHelper.context refreshObject:exercise mergeChanges:NO];
        [self reloadView];
    }
}

-(void)removeExerciseFromDatesUsingName:(NSString*)exerciseName {
    NSFetchRequest *fetchDates = [NSFetchRequest fetchRequestWithEntityName:@"Date"];
    [fetchDates setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    NSArray *fetchedDates = [self.coreDataHelper.context executeFetchRequest:fetchDates error:nil];
    
    [fetchedDates enumerateObjectsUsingBlock:^(Date * _Nonnull dateObject, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableSet *newSet = [dateObject.exercise mutableCopy];
        [dateObject.exercise enumerateObjectsUsingBlock:^(Exercise * _Nonnull obj, BOOL * _Nonnull stop) {
            if([exerciseName isEqualToString:obj.name]) {
                [newSet removeObject:obj];
            }
        }];
        dateObject.exercise = [newSet copy];
    }];
    [self.coreDataHelper backgroundSaveContext];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    ExerciseList *exercise = [self.frc objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [exercise.name stringByReplacingOccurrencesOfString:@"_" withString:@" "], exercise.unit];

    return cell;
}

#pragma mark - PICKERVIEW DATASOURCE
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.defaultUnits.count;
}
#pragma mark - PICKERVIEW DELEGATE
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return (NSString*)[self.defaultUnits objectAtIndex:row];
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self becomeFirstResponder];
    [self.textField resignFirstResponder];
    if(row == 0) {
        NSLog(@"Cant select that!");
        [unitTextFieldHolder setText:@""];
    } else {
        NSLog(@"You selected %@", [self.defaultUnits objectAtIndex:row]);
        [unitTextFieldHolder setText:[self.defaultUnits objectAtIndex:row]];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(BOOL)isValidStringLength:(NSString*)string {
    if(string.length > 30) {
        return NO;
    }
    return YES;
}
-(BOOL)isValidString:(NSString*)string {
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_"] invertedSet];
    
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
