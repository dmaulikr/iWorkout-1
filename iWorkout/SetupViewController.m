//
//  SetupViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "SetupViewController.h"
#import "AppDelegate.h"
#import "ExerciseList.h"

#define DebugMode 1

@interface SetupViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

//NSString * const customName = @"Create custom...";

@implementation SetupViewController
{
    BOOL firstSetupExists;
    NSMutableArray *newExercises;
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
    self.unitPicker.delegate = self;
    self.unitPicker.dataSource = self;
    
    [self.unitPicker reloadAllComponents];
    
    // Set up table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    
    
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
        //textfieldForAlert = textField;
        [textField setTextAlignment:NSTextAlignmentCenter];
        
        //int rowIndex = [self getDateIndex];
        //[pickerView selectRow:rowIndex inComponent:0 animated:YES];
        //[textField setText:[pickerArray objectAtIndex:rowIndex]];
        
    }];
    UIAlertAction *select = [UIAlertAction actionWithTitle:@"Select" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //textfieldForAlert = nil;
        //NSLog(@"You selected %@", [pickerView ][pickerView selectedRowInComponent:0]);
    }];
    [alert addAction:select];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ACTIONS
-(IBAction)help:(id)sender {
    UIAlertController *helpController = [UIAlertController alertControllerWithTitle:@"Instructions of use" message:@"Please enter a workout name and a unit of measurement to match, and continue doing so until you have all your workouts listed below.\n\ne.g. Workout name: Pushups\nUnit of measurement: Reps\n\n Workout name: Cycling\nUnit of measurement: Km" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                       //nil
                                                    }];
    [helpController addAction:dismiss];
    [self presentViewController:helpController animated:YES completion:nil];
    
}

-(void)createExercises {
    
}

-(IBAction)done:(id)sender {
    /*
    if(self.customData.count <= 0) {
        [self displayAlertwithTitle:@"Error: No entries added" withMessage:@"No workouts have been added.\nTap 'Help' on the top-left for more help."];
        return;
    }
    
    [self.customData enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(DebugMode) {
            NSLog(@"%@ (%@)", [obj valueForKey:@"WorkoutName"], [obj valueForKey:@"UnitOfMeasurement"]);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];

    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Setup.plist"];
    
    if(![self.customData writeToFile:path atomically:YES]) {
        if(DebugMode) {
            NSLog(@"ERROR: Unable to write to file.");
        }
    } else {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SetupComplete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        if(DebugMode) {
            NSLog(@"Success!");
        }
    }*/
    if(self.frc.fetchedObjects.count <= 0) {
        [self displayAlertwithTitle:@"Error: No entries added" withMessage:@"No workouts have been added.\nTap 'Help' on the top-left for more help."];
    }
    
    NSFetchRequest *totalExercises = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseList"];
    [totalExercises setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    NSArray *allObjects = [self.coreDataHelper.context executeFetchRequest:totalExercises error:nil];
    
    [allObjects enumerateObjectsUsingBlock:^(ExerciseList *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Exercise name: %@  &  isDouble: %@", obj.name, [obj.isDouble boolValue] ? @"Yes" : @"No");
    }];
    if(!firstSetupExists) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"FirstSetup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"First time set up complete.");
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:newExercises forKey:@"NewExercises"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }



    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)displayWarningAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.textField resignFirstResponder];
        [self.unitPicker becomeFirstResponder];
    }];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)displayErrorAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)addWorkout:(id)sender {
    if(!self.textField.text || [self.textField.text isEqualToString:@""]) {
        [self displayErrorAlertWithTitle:@"ERROR: Empty name" andMessage:@"Please enter a workout name"];
        return;
    }
    
    if(![self isValidStringLength:self.textField.text]) {
        [self displayErrorAlertWithTitle:@"Invalid String Length" andMessage:@"Please keep the workout name below 30 characters."];
        return;
    }
    int selectedRow = (int) [self.unitPicker selectedRowInComponent:0];
    
    
    if(![self illegalRowSelected:selectedRow]) {
        
        [self addExerciseWithName:[self replaceSpacesWithUnderscores:self.textField.text]];
        
        //[self addDataWithName:self.textField.text];
        if(DebugMode) {
            NSLog(@"Selected: %@", (NSString*)[self.defaultUnits objectAtIndex:selectedRow]);
        }
            [self.unitPicker selectRow:0 inComponent:0 animated:YES];
        }

}
-(BOOL)illegalRowSelected:(int)selectedRowIn {
    if(selectedRowIn == -1) {
        if(DebugMode) {
            NSLog(@"Nothing selected!");
        }
        return YES;
    } else if(selectedRowIn == 0) {
        if(DebugMode) {
            NSLog(@"NOT THAT EITHER");
        }
        [self displayWarningAlertWithTitle:@"Choose a unit" andMessage:@"Please select a unit of measurement"];
        return YES;
    } else {
        return NO;
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
    
    if(![self doesExerciseExist:name]) {
        if([self isValidString:name]) {
            NSString *unit = [self.defaultUnits objectAtIndex:[self.unitPicker selectedRowInComponent:0]];
            NSString *newName = [self changeFirstLetterToUppercase:name];
            if([unit isEqualToString:@"Reps"]) {
                [self addExerciseWithName:newName isDouble:NO];
            } else {
                [self addExerciseWithName:newName isDouble:YES];
            }
        } else {
            [self displayAlertwithTitle:@"Invalid Characters" withMessage:[NSString stringWithFormat:@"The entry '%@' \ncontains illegal characters. No symbols please", name]];
        }
    } else {
        [self displayWarningAlertWithTitle:@"ERROR" andMessage:@"Workout already exists."];
    }
    
    [self reloadView];
    self.textField.text = @"";
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
-(void)addExerciseWithName:(NSString*)name isDouble:(BOOL)isDouble {
    ExerciseList *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseList" inManagedObjectContext:self.coreDataHelper.context];
    
    exercise.name = name;
    exercise.isDouble = [NSNumber numberWithBool:isDouble];
    NSLog(@"Added Exercise %@ (isBool: %@)", name, isDouble ? @"true" : @"false");
    
    [self.coreDataHelper backgroundSaveContext];
    if(firstSetupExists) {
        // This means we're in editing mode.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:name forKey:@"Name"];
        [dict setObject:[NSNumber numberWithBool:isDouble] forKey:@"IsDouble"];
        [newExercises addObject:dict];
    }
}
/*
-(void)addDataWithName:(NSString*)name {
    [self.textField resignFirstResponder];
    
    NSString *newName;
    NSString *first = [name substringToIndex:1];
    
    // Replacing all occurences of spaces ' ' with underscores '_'
    newName = [[NSString stringWithFormat:@"%@%@", [first uppercaseString], [name substringFromIndex:1]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    
    if(![self entryAlreadyExists:newName]) {
        NSString *unit = [self.defaultUnits objectAtIndex:[self.unitPicker selectedRowInComponent:0]];
        if([self isValidString:newName]) {
        [self addDictWithName:newName andUnit:unit];
        } else {
            [self displayAlertwithTitle:@"Invalid Characters" withMessage:[NSString stringWithFormat:@"The entry '%@' \ncontains illegal characters. No symbols please", newName]];
        }
        
    } else {
        [self displayWarningAlertWithTitle:@"ERROR" andMessage:@"Workout already exists."];
    }
    
    [self.tableView reloadData];
    self.textField.text = @"";
}

-(void)addDictWithName:(NSString*)name andUnit:(NSString*)unit {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"WorkoutName"];
    [dict setValue:unit forKey:@"UnitOfMeasurement"];
    
    [self.customData addObject:[dict copy]];
}
*/
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
        [self.coreDataHelper.context deleteObject:exercise];
        [self.coreDataHelper backgroundSaveContext];
        NSLog(@"Deleted %@", objectName);
        
        [self.coreDataHelper.context refreshObject:exercise mergeChanges:NO];
        [self reloadView];
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //NSDictionary *dict = [self.customData objectAtIndex:indexPath.row];
    ExerciseList *exercise = [self.frc objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [exercise.name stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict valueForKey:@"WorkoutName"], [dict valueForKey:@"UnitOfMeasurement"]];

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
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.unitPicker.frame.size.width;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self becomeFirstResponder];
    [self.textField resignFirstResponder];
    NSLog(@"You selected %@", [self.defaultUnits objectAtIndex:row]);
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
-(void)displayAlertwithTitle:(NSString*)title withMessage:(NSString*)message
{
    //UIViewController *root = (UIViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       //[root dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:close];
    [self presentViewController:alert animated:YES completion:nil];
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
