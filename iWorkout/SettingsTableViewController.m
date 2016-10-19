//
//  SettingsTableViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 25/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
#import "DateFormat.h"
#import "SetupViewController.h"

#define DebugMode 1

@interface SettingsTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate>

@end

@implementation SettingsTableViewController
{
    NSArray *pickerArray;
    __block UITextField *textfieldForAlert;
    BOOL isLoadingActive;
}


-(IBAction)switchedOn:(id)sender
{
    UISwitch *theSwitch = (UISwitch*)sender;
    int switchTag = (int)theSwitch.tag;
    
    if(switchTag == 2) {
        // Auto Lock
        if(theSwitch.on) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"DisableAutoLock"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                if(DebugMode) {
                    NSLog(@"Disable auto lock is now ON");
                }
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate setAutoLock:YES];
            } else {
                if(DebugMode) {
                    NSLog(@"Error while saving settings");
                }
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"DisableAutoLock"];
            if([[NSUserDefaults standardUserDefaults] synchronize]) {
                if(DebugMode) {
                    NSLog(@"Disable auto lock is now OFF");
                }
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate setAutoLock:NO];
            } else {
                if(DebugMode) {
                    NSLog(@"Error while saving settings");
                }
            }
        }
    }
}
-(void)setAppropriateLoadedSettings {
    // Load the date format
    if([self dateIndexExists]) {
        int dateIndex = [self getDateIndex];
        
        [self.dateStyleLabel setText:[pickerArray objectAtIndex:dateIndex]];
        if(DebugMode) {
            NSLog(@"Date index: %i", dateIndex);
            NSLog(@"Loaded date settings");
        }
    } else {
        if(DebugMode) {
            NSLog(@"No date index exists.. Set to default.");
        }
        [self.dateStyleLabel setText:[pickerArray objectAtIndex:0]];
    }

    // Load Auto-Lock settings
    if([self autoLockExists]){
        // Set the appropriate existing switch on view
        BOOL disableAutoLock;
        disableAutoLock = [[[NSUserDefaults standardUserDefaults] valueForKey:@"DisableAutoLock"] boolValue];
        [self.autoLockSwitch setOn:disableAutoLock];
        if(DebugMode) {
            NSLog(@"Auto lock is: %@", disableAutoLock ? @"ON" : @"OFF");
        }
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
    isLoadingActive = NO;
    // Moved the array of available dates to the DateFormat Class.
    pickerArray = [[NSArray alloc] initWithArray:[DateFormat getAvailableDates]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Settings"];

    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleDone target:self action:@selector(showHelp)];
    
    self.navigationItem.rightBarButtonItem = helpButton;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!isLoadingActive) {
        isLoadingActive = YES;
        NSLog(@"Loading....");
        [self performSelectorOnMainThread:@selector(setAppropriateLoadedSettings) withObject:nil waitUntilDone:YES];
        
        //[self setAppropriateLoadedSettings];
        isLoadingActive = NO;
        NSLog(@"Loading complete!");
    }
    
}
-(void)viewWillLayoutSubviews {
    // This runs 3 times (?)
    

}

-(void)showHelp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Help" message:@"Tap the Date on the Date Format to change the format\nTap \'Clear all days\' to start your workouts from today\nTap \'Factory Reset\' if you would like to erase all data and start new" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
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
    if(DebugMode) {
        NSLog(@"Selected Dateformat Index: %i", (int)row);
    }
    [self setSelectedDateFormat:(int)row];
    [self updateAlertWithIndex:(int)row];
}


#pragma mark - ERASING DATA
-(void)confirmFactoryReset {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Erase All Content" message:@"Are you sure you want to continue erasing all data?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self eraseAllContent];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(DebugMode) {
            NSLog(@"Cancelled reset");
        }
    }];
    [alertC addAction:yesAction];
    [alertC addAction:cancelAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)eraseAllContent {
    if([self removeSetupFile]) {
        if([self removeStoresDirectory]) {
            if(DebugMode) {
                NSLog(@"Successfully erased all content!");
            }
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
            if(DebugMode) {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
            return NO;
        } else {
            if(DebugMode) {
                NSLog(@"Successfully deleted setup file. ");
            }
            return YES;
        }
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: File doesn't exist..");
        }
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
            if(DebugMode) {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
            return NO;
        } else {
            if(DebugMode) {
                NSLog(@"Successfully deleted Stores directory. ");
            }
            return YES;
        }
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: Stores directory doesn't exist..");
        }
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
            if(DebugMode) {
                NSLog(@"Success!");
            }
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:indexOfDateFormat] forKey:@"DateFormatIndex"];
        if([[NSUserDefaults standardUserDefaults] synchronize]) {
            if(DebugMode) {
                NSLog(@"Success!");
            }
        }
    }
}
-(void)openSetupPage {
    NSLog(@"Opening setup page...");
    SetupViewController *setupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SetupViewController"];

    setupVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:setupVC animated:YES completion:nil];
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self openSetupPage];
                break;
            case 1:
                [self displayDateSelection];
                break;
                
            default:
                break;
        }
    }
    if(indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                if(DebugMode) {
                    NSLog(@"Delete all workout days..");
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                //[self deleteAllWorkoutsIndexPath:indexPath];
                [self confirmDeleteAllWorkouts];
                break;
            case 1:
                if(DebugMode) {
                    NSLog(@"Erasing all content...");
                }
                [self confirmFactoryReset];
                break;
            default:
                break;
        }
    } else if(indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // To ensure the top settings are not selectable.
    }
}

-(void)displayDateSelection {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Date Format" message:@"Select your preferred date style" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setInputView:pickerView];
        textfieldForAlert = textField;
        [textField setTextAlignment:NSTextAlignmentCenter];
        
        int rowIndex = [self getDateIndex];
        [pickerView selectRow:rowIndex inComponent:0 animated:YES];
        [textField setText:[pickerArray objectAtIndex:rowIndex]];
        
    }];
    UIAlertAction *select = [UIAlertAction actionWithTitle:@"Select" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        textfieldForAlert = nil;
    }];
    [alert addAction:select];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)updateAlertWithIndex:(int)index {
    textfieldForAlert.text = [NSString stringWithString:[pickerArray objectAtIndex:index]];
}

-(void)confirmDeleteAllWorkouts {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Delete" message:@"Are you sure you would like to delete all your current workout days?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAllWorkouts];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Do nothing.
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)deleteAllWorkouts {
    @autoreleasepool {
        NSError *error;
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
        [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:NO]]];
        NSArray *fetchedObjects = [appDelegate.coreDataHelper.context executeFetchRequest:fetch error:&error];
        
        if(fetchedObjects) {
            for(NSManagedObject *object in fetchedObjects) {
                [appDelegate.coreDataHelper.context deleteObject:object];
            }
            if(DebugMode) {
                NSLog(@"Successfully deleted objects.");
            }
            [appDelegate.coreDataHelper backgroundSaveContext];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Successfully deleted all workouts" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            if(DebugMode) {
                NSLog(@"ERROR: Unable to fetch objects!");
            }
            return;
        }
    }
}


@end
