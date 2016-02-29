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

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the default array of units and customWorkouts
    self.defaultUnits = [[NSMutableArray alloc] initWithObjects:@"Pick a unit",@"Reps",@"Km",@"Miles",@"Add custom...", nil];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ACTIONS
-(void)displayWarningAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.textField resignFirstResponder];
        [self.unitPicker becomeFirstResponder];
        //[alertController dismissViewControllerAnimated:YES completion:nil];
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
    // Type check etc,
    
    if(self.textField.text) {
        if([self.textField.text isEqualToString:@""]) {
            [self displayErrorAlertWithTitle:@"ERROR" andMessage:@"Please enter a workout name"];
            return;
        } else {
    int selectedRow = (int) [self.unitPicker selectedRowInComponent:0];
    
    //NSLog(@"selected: %i", selectedRow);
    
    if(selectedRow == -1) {
        NSLog(@"Nothing selected!");
    } else if(selectedRow == 0) {
        NSLog(@"NOT THAT EITHER");
        [self displayWarningAlertWithTitle:@"Choose a unit" andMessage:@"Please select a unit of measurement"];
    } else {
        [self addDataWithName:self.textField.text];
        NSLog(@"Selected: %@", (NSString*)[self.defaultUnits objectAtIndex:selectedRow]);
    }
        }
    }
}
-(void)addDataWithName:(NSString*)name {
    [self.textField resignFirstResponder];
    
    NSString *newName;
    NSString *first = [name substringToIndex:1];
    newName = [NSString stringWithFormat:@"%@%@", [first uppercaseString], [name substringFromIndex:1]];
    
    
    if(![self entryAlreadyExists:newName]) {
        //[self.customWorkouts addObject:newName];
        NSString *unit = [self.defaultUnits objectAtIndex:[self.unitPicker selectedRowInComponent:0]];
        [self addDictWithName:newName andUnit:unit];
        
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
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    //cell.textLabel.text = [self.customWorkouts objectAtIndex:indexPath.row];
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
   // NSLog(@"Selected new one!");
    [self.textField resignFirstResponder];
}


-(BOOL)prefersStatusBarHidden {
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
