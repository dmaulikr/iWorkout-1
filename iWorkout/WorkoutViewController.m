//
//  WorkoutViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 10/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "WorkoutViewController.h"


@interface WorkoutViewController ()

@end

@implementation WorkoutViewController
{
    NSString *textOfLabel;
    CoreDataHelper *cdh;
    
    NSManagedObjectID *objectID;
    NSManagedObject *workout;
    NSArray *arrayOfUnits;
    NSArray *arrayOfWorkouts;
}
@synthesize dateLabel, dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dateformatter = [[NSDateFormatter alloc] init];
    [self.dateformatter setDateFormat:@"dd-MM-yy"];
    self.modFormatter = [[NSDateFormatter alloc] init];
    
    //[self.modFormatter setDateFormat:@"dd-MM-yy HH:mm:ss"];
    [self.modFormatter setDateFormat:@"HH:mm:ss"];
    
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    dateLabel.text = textOfLabel;
    
    [self setupData];
    
    [self createButtonOnNav];
    
    // new feature
    //self.lastModifiedLabel.text = [self getModified];
    
    [self lastModded];
}
-(void)lastModded {
    NSString *lastMod = [self compareDates];
    
    if(lastMod) {
        self.lastModifiedLabel.text = [NSString stringWithFormat:@"%@ (%@ ago)", [self getModified], lastMod];
    }
    else {
        self.lastModifiedLabel.text = [self getModified];
    }
}
-(NSString*)getModified {

    NSString *lastModded = [self.modFormatter stringFromDate:(NSDate*)[workout valueForKey:@"LastModified"]];
    
    if([lastModded isEqualToString:@""] || !lastModded) {
        return @"Last modified: null";
    }
    return [NSString stringWithFormat:@"Last modified: %@", lastModded];
}
-(NSString*)compareDates {
    // USE THIS INSTEAD
    // ****************
    // http://stackoverflow.com/questions/10373911/how-to-calculate-time-difference-in-minutes-between-two-dates-in-ios
    
    NSMutableString *string = [NSMutableString string];
    NSDate *nowDate = [NSDate date];
    NSDate *dateModified = (NSDate*)[workout valueForKey:@"LastModified"];
    
    if(!dateModified) {
        NSLog(@"ERROR: No last modified date found");
        return nil;
    }
    /*
    NSDateFormatter *hourFormatter = [NSDateFormatter new];
    [hourFormatter setDateFormat:@"HH"];
    
    NSDateFormatter *minFormatter = [NSDateFormatter new];
    [minFormatter setDateFormat:@"mm"];
    
    NSDateFormatter *secFormatter = [NSDateFormatter new];
    [secFormatter setDateFormat:@"ss"];
    
    if(![[hourFormatter stringFromDate:nowDate] isEqualToString:[hourFormatter stringFromDate:laterDate]]) {
        int currentHour = [[hourFormatter stringFromDate:nowDate] intValue];
        int modifiedHour = [[hourFormatter stringFromDate:laterDate] intValue];
        
        int differenceInHours = currentHour - modifiedHour;
        
        NSLog(@"(HOUR) %i - %i = %i", currentHour, modifiedHour, differenceInHours);
        
        if(differenceInHours > 0) {
            NSString *hourName = [NSString stringWithFormat:@"%@", (differenceInHours > 1) ? @"hours" : @"hour"];
            [string appendString:[NSString stringWithFormat:@"%i %@ ", differenceInHours, hourName]];
        }
    }
    
    if(![[minFormatter stringFromDate:nowDate] isEqualToString:[minFormatter stringFromDate:laterDate]]) {
        int currentMin = [[minFormatter stringFromDate:nowDate] intValue];
        int modifiedMin = [[minFormatter stringFromDate:laterDate] intValue];
        
        int differenceInMins = currentMin - modifiedMin;
        
        NSLog(@"(MIN) %i - %i = %i", currentMin, modifiedMin, differenceInMins);
        
        if(differenceInMins > 0) {
            [string appendString:[NSString stringWithFormat:@"%i mins ", differenceInMins]];
         }
    }
    if(![[secFormatter stringFromDate:nowDate] isEqualToString:[secFormatter stringFromDate:laterDate]]) {
        int currentSec = [[secFormatter stringFromDate:nowDate] intValue];
        int modifiedSec = [[secFormatter stringFromDate:laterDate] intValue];
        
        int differenceInSecs = currentSec - modifiedSec;
        
        NSLog(@"(SEC) %i - %i = %i", currentSec, modifiedSec, differenceInSecs);
        
        if(differenceInSecs > 0) {
           [string appendString:[NSString stringWithFormat:@"%i secs ", differenceInSecs]];
        }
    }
    */
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:dateModified];
    
    if((timePassed/60) > 60) {
        if(((timePassed/60)/60) > 24) {
            [string appendString:[NSString stringWithFormat:@"%.0f days", (((timePassed/60)/60)/24)]];
        } else {
            [string appendString:[NSString stringWithFormat:@"%.2f hours", (timePassed/60)/60]];
        }
    } else if((timePassed/60) < 1) {
        [string appendString:[NSString stringWithFormat:@"%.0f seconds", timePassed]];
    } else {
        [string appendString:[NSString stringWithFormat:@"%.0f minutes", timePassed/60]];
    }
    
    if(string) {
        NSLog(@"Date was modified: %@ ago", string);
        return string;
    }
    return nil;
}
-(void)createButtonOnNav {
    //self.navigationItem.title = dateLabel.text;
    NSDateFormatter *newFormat = [NSDateFormatter new];
    [newFormat setDateFormat:@"EEEE dd"];
    
    NSDate *workoutDate = (NSDate*)[workout valueForKey:@"Date"];
    NSString *navTitle = [NSString stringWithFormat:@"%@%@",[newFormat stringFromDate:workoutDate],[self getSuffixForDate:workoutDate]];
    self.navigationItem.title = navTitle;
    
   // NSDateFormatter *testformatter = [NSDateFormatter new];
    //[testformatter setDateFormat:@"LLLL"];
    
    //NSLog(@"This is: %@", [NSString stringWithFormat:@"%@ %@",navTitle, [testformatter stringFromDate:workoutDate]]);
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addReps)];
    self.navigationItem.rightBarButtonItem = addButton;
}
-(NSString *)getSuffixForDate:(NSDate*)theDate
{
    NSDateFormatter *dayOf = [NSDateFormatter new];
    [dayOf setDateFormat:@"dd"];
    
    int number = [[dayOf stringFromDate:theDate] intValue];
    
    NSString *suffix;
    
    int ones = number % 10;
    int tens = (number/10) % 10;
    
    if (tens ==1) {
        suffix = [NSString stringWithFormat:@"th"];
    } else if (ones ==1){
        suffix = [NSString stringWithFormat:@"st"];
    } else if (ones ==2){
        suffix = [NSString stringWithFormat:@"nd"];
    } else if (ones ==3){
        suffix = [NSString stringWithFormat:@"rd"];
    } else {
        suffix = [NSString stringWithFormat:@"th"];
    }
    return suffix;
}

-(void)setupData {
    workout = (NSManagedObject*)[cdh.context objectWithID:objectID];
    
    arrayOfUnits = [AppDelegate getUnits];
    arrayOfWorkouts = [AppDelegate getWorkouts];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
-(void)sendObject:(NSManagedObjectID*)objIn {
    //managedObject = objIn;
    
    objectID = objIn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDateLabelText:(NSString*)textIn {
    textOfLabel = textIn;
}
-(void)requestEntryToAddAtIndex:(NSInteger)indexPass {
    __block BOOL isFloat;
    
    NSString *unitName = (NSString*)[arrayOfUnits objectAtIndex:_selectedIndexPath.row];
    if([unitName isEqualToString:@"Miles"] || [unitName isEqualToString:@"Km"] || [unitName isEqualToString:@"Mins"]) {
        isFloat = YES;
    } else {
        isFloat = NO;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add" message:@"Enter data to add:" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if(isFloat) {
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }
        else {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    }];
    __block NSNumber *countToAdd;
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(isFloat) {
            float oldValue = [[workout valueForKey:[arrayOfWorkouts objectAtIndex:indexPass]] floatValue];
            NSNumber *newValue = [NSNumber numberWithFloat:(oldValue+[alertController.textFields.firstObject.text floatValue])];
            countToAdd = newValue;
        } else {
            int oldValue = [[workout valueForKey:[arrayOfWorkouts objectAtIndex:indexPass]] intValue];
            NSNumber *newValue = [NSNumber numberWithInt:(oldValue+[alertController.textFields.firstObject.text intValue])];
            countToAdd = newValue;
        }
        [self addEntry:countToAdd toWorkoutAtIndex:indexPass];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [alertController addAction:cancel];
    [alertController addAction:add];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)modifiedData {
    [workout setValue:[NSDate date] forKey:@"LastModified"];
    
    // Change the date of when it was modified on the label
    // this is temp.
    self.lastModifiedLabel.text = [NSString stringWithFormat:@"Last modified: %@", [self.modFormatter stringFromDate:[NSDate date]]];
}
-(void)addEntry:(NSNumber*)number toWorkoutAtIndex:(NSInteger)index {
    
    [workout setValue:number forKey:[arrayOfWorkouts objectAtIndex:index]];
    
    // New feature:
    [self modifiedData];
    
    [cdh backgroundSaveContext];
    [self.tableView reloadData];
}
-(void)addReps {
    if(!_selectedIndexPath) {
        NSLog(@"Nothing is selected.");
        return;
    } else {
        [self requestEntryToAddAtIndex:_selectedIndexPath.row];
    }
    
    [self unSelectRowAtIndexPath:_selectedIndexPath];
    
    _selectedWorkout = nil;
    _selectedIndexPath = nil;
    
}
-(NSString*)checkAndReplaceUnderscores:(NSString*)string {
    return [string stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    int rowNum = (int)indexPath.row;
    
    NSString *name = (NSString*)[arrayOfWorkouts objectAtIndex:rowNum];
    
    NSString *unit = (NSString*)[arrayOfUnits objectAtIndex:rowNum];
    
    NSNumber *reps;
    if([unit isEqualToString:@"Miles"] || [unit isEqualToString:@"Km"] || [unit isEqualToString:@"Mins"]) {
        reps = [NSNumber numberWithFloat:[[workout valueForKey:name] floatValue]];
    } else {
        reps = [NSNumber numberWithInt:[[workout valueForKey:name] intValue]];
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ = %@ (%@)", [self checkAndReplaceUnderscores:name], reps, unit];
    
    
    return cell;
}
-(void)unSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"You selected: %@", [arrayOfWorkouts objectAtIndex:indexPath.row]);
    
    [_selectedWorkout setString:[arrayOfWorkouts objectAtIndex:indexPath.row]];
    _selectedIndexPath = indexPath;
    
    [self addReps];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayOfWorkouts.count;
}
-(BOOL)prefersStatusBarHidden {
    return NO;
}


@end
