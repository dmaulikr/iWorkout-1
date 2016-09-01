//
//  SetupViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "SetupViewController.h"


@interface SetupViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

NSString * const customName = @"Create custom...";

@implementation SetupViewController

#warning Maybe consider replacing the '+' button with 'Add workout'
 

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the default array of units and customWorkouts
    self.defaultUnits = [[NSMutableArray alloc] initWithObjects:@"Choose one...",@"Reps",@"Km",@"Miles",@"Mins", nil];
    
    
    self.customWorkouts = [[NSMutableArray alloc] init];
    
    // Custom dictionary
    self.customData = [[NSMutableArray alloc] init];
    
    // Set up the unit pickerView
    self.unitPicker.delegate = self;
    self.unitPicker.dataSource = self;
    
    [self.unitPicker reloadAllComponents];
    
    // Set up table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(IBAction)done:(id)sender {
    if(self.customData.count <= 0) {
        [self displayAlertwithTitle:@"Error: No entries added" withMessage:@"No workouts have been added.\nTap 'Help' on the top-left for more help."];
        return;
    }
    
    [self.customData enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ (%@)", [obj valueForKey:@"WorkoutName"], [obj valueForKey:@"UnitOfMeasurement"]);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];

    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Setup.plist"];
    
    if(![self.customData writeToFile:path atomically:YES]) {
        NSLog(@"ERROR: Unable to write to file.");
    } else {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SetupComplete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Success!");
    }
    
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
            [self addDataWithName:self.textField.text];
            NSLog(@"Selected: %@", (NSString*)[self.defaultUnits objectAtIndex:selectedRow]);
            [self.unitPicker selectRow:0 inComponent:0 animated:YES];
        }

}
-(BOOL)illegalRowSelected:(int)selectedRowIn {
    if(selectedRowIn == -1) {
        NSLog(@"Nothing selected!");
        return YES;
    } else if(selectedRowIn == 0) {
        NSLog(@"NOT THAT EITHER");
        [self displayWarningAlertWithTitle:@"Choose a unit" andMessage:@"Please select a unit of measurement"];
        return YES;
    } else {
        return NO;
    }
    
}

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

#pragma mark - TABLEVIEW DATASOURCE
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return self.customWorkouts.count;
    return self.customData.count;
}
#pragma mark - TABLEVIEW DELEGATE
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.customData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *dict = [self.customData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict valueForKey:@"WorkoutName"], [dict valueForKey:@"UnitOfMeasurement"]];

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
