//
//  SettingsTableViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 25/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate>


@end

@implementation SettingsTableViewController
{
    NSArray *pickerArray;
}

-(IBAction)switchedOn:(id)sender
{
    UISwitch *theSwitch = (UISwitch*)sender;
    int switchTag = (int)theSwitch.tag;
    
    if(switchTag == 1) {
        // Auto save
        if(theSwitch.on) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"AutoSaveData"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                NSLog(@"Auto save is now ON");
            } else {
                NSLog(@"Error while saving settings");
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"AutoSaveData"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                NSLog(@"Auto save is now OFF");
            } else {
                NSLog(@"Error while saving settings");
            }
        }
    } else {
        // Auto Lock
        if(theSwitch.on) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"DisableAutoLock"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                NSLog(@"Disable auto lock is now ON");
            } else {
                NSLog(@"Error while saving settings");
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"DisableAutoLock"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                NSLog(@"Disable auto lock is now OFF");
            } else {
                NSLog(@"Error while saving settings");
            }
        }
    }
   
}
-(void)setAppropriateLoadedSettings {
    // Load the date format
    if([self dateIndexExists]) {
        int dateIndex = [self getDateIndex];
        if(dateIndex == 1) {
            [self.dateformatPicker selectRow:1 inComponent:0 animated:YES];
        } else if(dateIndex == 2) {
            [self.dateformatPicker selectRow:2 inComponent:0 animated:YES];
        }
        NSLog(@"Loaded date settings");
    }
    
    // Load Auto-Save settings
    if([self autoSaveExists]) {
        // Set the appropriate existing switch on view
        BOOL autoSaveOn;
        autoSaveOn = [[[NSUserDefaults standardUserDefaults] valueForKey:@"AutoSaveData"] boolValue];
        [self.autoSaveSwitch setOn:autoSaveOn];
        
    } else {
        [self.autoSaveSwitch setOn:NO];
    }
    
    // Load Auto-Lock settings
    if([self autoLockExists]){
        // Set the appropriate existing switch on view
        BOOL disableAutoLock;
        disableAutoLock = [[[NSUserDefaults standardUserDefaults] valueForKey:@"DisableAutoLock"] boolValue];
        [self.autoLockSwitch setOn:disableAutoLock];
        
    } else {
        [self.autoLockSwitch setOn:NO];
    }
    
}
-(BOOL)autoLockExists {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
           
    if([userDefaults valueForKey:@"DisableAutoLock"]) {
        return YES;
    } else {
        return NO;
    }
}
-(BOOL)autoSaveExists {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults valueForKey:@"AutoSaveData"]) {
        return YES;
    } else {
        return NO;
    }
}
-(BOOL)dateIndexExists {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults valueForKey:@"DateFormatIndex"]) {
        return YES;
    } else {
        return NO;
    }
}
-(int)getDateIndex {
    if([self dateIndexExists]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //NSLog(@"Dateformatindex is: %i", [[userDefaults valueForKey:@"DateFormatIndex"] intValue]);
        return [[userDefaults valueForKey:@"DateFormatIndex"] intValue];
    } else {
        return 0;
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    pickerArray = [NSArray arrayWithObjects:@"25-03-16",@"25th March 16",@"Friday 25th", nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillLayoutSubviews {
    [self setAppropriateLoadedSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIPickerView

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = (NSString*)[pickerArray objectAtIndex:row];
    
    
    return title;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerArray count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected Dateformat Index: %i", (int)row);
    [self setSelectedDateFormat:(int)row];
}


#pragma mark - ERASING DATA
-(void)confirmFactoryReset {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Erase All Content" message:@"Are you sure you want to continue erasing all data?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self eraseAllContent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // determine what cancel will actually do lol
        NSLog(@"Cancelled reset");
    }];
    
    [alertC addAction:yesAction];
    [alertC addAction:cancelAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)eraseAllContent {
    if([self removeSetupFile]) {
        if([self removeStoresDirectory]) {
            NSLog(@"Successfully erased all content!");
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Reset Complete" message:@"Application will now exit, please re-open iWorkout to start setup." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            [alertC addAction:dismiss];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }
}
-(BOOL)removeSetupFile {
    NSString *applicationDocumentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *setupPath = [applicationDocumentsDirectoryPath stringByAppendingPathComponent:@"Setup.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:setupPath]) {
        if(![fileManager removeItemAtPath:setupPath error:&error]) {
            NSLog(@"ERROR: %@", error.localizedDescription);
            return NO;
        } else {
            NSLog(@"Successfully deleted setup file. ");
            return YES;
        }
    } else {
        NSLog(@"ERROR: File doesn't exist..");
        return NO;
    }
}


-(BOOL)removeStoresDirectory {
    NSString *applicationDocumentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *storesDirectory = [applicationDocumentsDirectoryPath stringByAppendingPathComponent:@"Stores"];
    //NSString *fullStorePath = @"iWorkout.sqlite"; - Just remove the directory instead...
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:storesDirectory]) {
        if(![fileManager removeItemAtPath:storesDirectory error:&error]) {
            NSLog(@"ERROR: %@", error.localizedDescription);
            return NO;
        } else {
            NSLog(@"Successfully deleted Stores directory. ");
            return YES;
        }
    } else {
        NSLog(@"ERROR: Stores directory doesn't exist..");
        return NO;
    }
}
/*
 * END OF THE METHODS ---- (DELETION METHODS)
 */
-(void)setSelectedDateFormat:(int)indexOfDateFormat {
    if(indexOfDateFormat == 0) {
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"DateFormatIndex"];
        if([[NSUserDefaults standardUserDefaults] synchronize]) {
            NSLog(@"Success!");
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:indexOfDateFormat] forKey:@"DateFormatIndex"];
        if([[NSUserDefaults standardUserDefaults] synchronize]) {
            NSLog(@"Success!");
        }
    }

}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Delete all workout days..");
                [self deleteAllWorkoutsIndexPath:indexPath];
                break;
            case 1:
                NSLog(@"Erasing all content...");
                [self confirmFactoryReset];
                break;
            default:
                break;
        }
    }
}

-(void)deleteAllWorkoutsIndexPath:(NSIndexPath*)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"This function is not available yet." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    [alert addAction:dismiss];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}*/


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
