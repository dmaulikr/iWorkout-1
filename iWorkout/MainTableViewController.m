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
#import "ThumbnailCreator.h"

@interface MainTableViewController () 
@end

@implementation MainTableViewController
{
    CoreDataHelper *cdh;
}
-(BOOL)hasLatestDateBeenCreated {
    NSString *todaysDate;
    NSString *topCellName;
    
    if([self getDateIndex] <= 0) {
        todaysDate = [self.dateformatter stringFromDate:[NSDate date]];
        topCellName = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text;
    } else {
        todaysDate = [self getDatenameFromDate:[NSDate date]];
        topCellName = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text;
    }
        
    NSLog(@"%@ vs %@: %@", todaysDate, topCellName, [todaysDate isEqualToString:topCellName] ? @"YES" : @"NO");
    if(![todaysDate isEqualToString:topCellName]) {
        return NO;
    } else {
        return YES;
    }
}
-(void)refreshDate {
    [self performFetch];
    [self.tableView reloadData];
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

-(NSString*)getDatenameFromDate:(NSDate*)date {
    int dateIndex = [self getDateIndex];
    
    if(dateIndex <= 0) {
       return [self.dateformatter stringFromDate:date];
    } else if(dateIndex == 1) {
        NSDateFormatter *dayFormat = [NSDateFormatter new];
        [dayFormat setDateFormat:@"dd"];
        NSDateFormatter *restFormat = [NSDateFormatter new];
        [restFormat setDateFormat:@"LLLL yy"];
        NSString *string = [NSString stringWithFormat:@"%@%@ %@", [dayFormat stringFromDate:date],[self getSuffixForDate:date],[restFormat stringFromDate:date]];
        
        return string;
    } else if(dateIndex == 2) {
        NSDateFormatter *dayFormat = [NSDateFormatter new];
        [dayFormat setDateFormat:@"EEEE dd"];
        
        NSString *string = [NSString stringWithFormat:@"%@%@",[dayFormat stringFromDate:date],[self getSuffixForDate:date]];
        return string;
    } else {
        NSLog(@"ERROR: Please refer to getDatenameFromDate method!");
        return nil;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dateformatter = [[NSDateFormatter alloc] init];
    [self.dateformatter setDateFormat:@"dd-MM-yy"];
    
    NSLog(@"Date index is: %i", [[[NSUserDefaults standardUserDefaults] valueForKey:@"DateFormatIndex"] intValue]);

    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDate)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    [self configureFetch];
    [self performFetch];
    
    // Check to make sure objects are returned, otherwise create todays entry
    if(self.frc.fetchedObjects.count <= 0) {
        NSLog(@"No data found!");
        
        // Creating today entry
        [self addTodayEntry];
        
        // Updating view
        [self refreshDate];
    }
    
    
    // Check to make sure todays entry exists
    if([self hasLatestDateBeenCreated]) {
        NSLog(@"Latest entry is todays date, everythings a go.");
    } else {
        NSLog(@"Latest entry is not todays date, attempting to add todays date");
        [self addTodayEntry];
        NSLog(@"Added todays entry.. ");
        [self performSelector:@selector(delayConfirm) withObject:nil afterDelay:0.1]; // Added short delay to ensure DB has a lil time to load.
    }

}
-(void)delayConfirm {
    // Update view
    [self refreshDate];
    
    if([self hasLatestDateBeenCreated]) {
        NSLog(@"Success!");
    } else {
        NSLog(@"ERROR: Database taking longer than usual..");
        
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

#pragma mark - CUSTOM DATA ENTRY (COMMENT OUT WHEN NOT USED)
/*
-(void)addOldEntries {
    
    //
    // Setup data:
    // Pullups, Pushups, Situps, Leg_raises, Squats, Cycling
    //
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yy"];
    
    
    // Creation of workouts
    NSManagedObject *the11th = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    NSManagedObject *the12th = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    NSManagedObject *the13th = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    
    // Set the date through property values
    NSDateFormatter *newFormatter = [NSDateFormatter new];
    [newFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    // 2016-04-15T06:10:43+01:00
    NSDate *the11thDate = [newFormatter dateFromString:@"2016-04-11T06:10:43+01:00"];
    NSDate *the12thDate = [newFormatter dateFromString:@"2016-04-12T06:10:43+01:00"];
    NSDate *the13thDate = [newFormatter dateFromString:@"2016-04-13T06:10:43+01:00"];
    
    
    // Set the workouts for 11-04-16
    [the11th setValue:the11thDate forKey:@"Date"];
    [the11th setValue:@19 forKey:@"Pullups"];
    [the11th setValue:@110 forKey:@"Pushups"];
    [the11th setValue:@150 forKey:@"Situps"];
    [the11th setValue:@0 forKey:@"Leg_raises"];
    [the11th setValue:@0 forKey:@"Squats"];
    [the11th setValue:@8.0 forKey:@"Cycling"];
    
    // Set the workouts for 12-04-16
    [the12th setValue:the12thDate forKey:@"Date"];
    [the12th setValue:@0 forKey:@"Pullups"];
    [the12th setValue:@36 forKey:@"Pushups"];
    [the12th setValue:@0 forKey:@"Situps"];
    [the12th setValue:@0 forKey:@"Leg_raises"];
    [the12th setValue:@0 forKey:@"Squats"];
    [the12th setValue:@0.0 forKey:@"Cycling"];
    
    // Set the workouts for 13-04-16
    [the13th setValue:the13thDate forKey:@"Date"];
    [the13th setValue:@25 forKey:@"Pullups"];
    [the13th setValue:@100 forKey:@"Pushups"];
    [the13th setValue:@100 forKey:@"Situps"];
    [the13th setValue:@0 forKey:@"Leg_raises"];
    [the13th setValue:@0 forKey:@"Squats"];
    [the13th setValue:@3.71 forKey:@"Cycling"];
    
    // set date modified
    
    // 2016-04-15T06:10:43+01:00
    
    // 2016-04-13T12:38:21+01:00
    
    NSDate *the11thModifiedDate = [newFormatter dateFromString:@"2011-07-13T12:38:21+01:00"];
    NSDate *the12thModifiedDate = [newFormatter dateFromString:@"2016-04-12T14:57:45+01:00"];
    NSDate *the13thModifiedDate = [newFormatter dateFromString:@"2016-04-14T22:21:05+01:00"];
    
    
    if(the11thModifiedDate) {
        [the11th setValue:the11thModifiedDate forKey:@"LastModified"];
    } else {
        NSLog(@"(11th) Couldn't parse string..");
    }
    if(the12thModifiedDate) {
        [the12th setValue:the12thModifiedDate forKey:@"LastModified"];
    } else {
        NSLog(@"(12) Couldnt parse string..");
    }
    if(the13thModifiedDate) {
        [the13th setValue:the13thModifiedDate forKey:@"LastModified"];
    } else {
        NSLog(@"(13) Couldnt parse string..");
    }
    
    
    [cdh backgroundSaveContext];
}*/

-(void)performFetch {
    if(self.frc) {
        [self.frc.managedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            
            if(![self.frc performFetch:&error]) {
                NSLog(@"Failed to perform fetch: %@", error);
            } else {
                NSLog(@"Fetch performed successfully!"); // I added this in, unnecessary
            }
            [self.tableView reloadData];
        }];
    } else {
        NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
}
-(void)configureFetch {
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:NO]];
    
    // Unsure about this...
    [request setFetchBatchSize:15];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    //self.frc.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
        
        // Lets remove this....
        NSString *todayText = [self.dateformatter stringFromDate:[object valueForKey:@"Date"]];
        //cell.textLabel.text = [self.dateformatter stringFromDate:[object valueForKey:@"Date"]];
        
        // And try this..
        cell.textLabel.text = [self getDatenameFromDate:(NSDate*)[object valueForKey:@"Date"]];
        
        NSString *today = [self.dateformatter stringFromDate:[NSDate date]];
        if([todayText isEqualToString:today]) {
            //UIImage *image = [UIImage imageNamed:@"greenbutton.png"];
            cell.imageView.image = [ThumbnailCreator createThumbnailWithImage:[UIImage imageNamed:@"greenbutton"]];
            //NSLog(@"GREEN");
        } else {
          //  UIImage *image = [UIImage imageNamed:@"redbutton.png"];
            cell.imageView.image = [ThumbnailCreator createThumbnailWithImage:[UIImage imageNamed:@"redbutton"]];
            //NSLog(@"RED");
        }
    // Configure the cell...
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];
    //NSDictionary *dict = (NSDictionary*)[self.frc objectAtIndexPath:indexPath];
    
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    
    //NSArray *retrievedArray = [AppDelegate getWorkouts];
    //NSArray *retrievedUnits = [AppDelegate getUnits];
    /*
    [retrievedArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ (%@): %@", (NSString*)[retrievedArray objectAtIndex:idx], (NSString*)[retrievedUnits objectAtIndex:idx], [object valueForKey:obj]);
    }];*/
    
    
    
    NSString *dateL = [NSString stringWithFormat:@"%@", [self.dateformatter stringFromDate:[object valueForKey:@"Date"]]];
    
    [workoutVC setDateLabelText:dateL];
    
    if([cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:object] error:nil]) {
        [workoutVC sendObject:object.objectID];
    } else {
        NSLog(@"ERROR: No ID found for selected object.");
    }
    
    
    [self.navigationController pushViewController:workoutVC animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


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
        
        NSLog(@"Deleted object");
        //[self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // do nothing.
        NSLog(@"Cancelled by user.");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
    

    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

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
