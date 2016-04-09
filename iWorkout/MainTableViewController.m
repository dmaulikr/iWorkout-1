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
#import "CustomTableViewCell.h"
#import "ThumbnailCreator.h"

@interface MainTableViewController () 
@end

@implementation MainTableViewController
{
    CoreDataHelper *cdh;
}
-(BOOL)hasLatestDateBeenCreated {
    
    NSString *todaysDate = [self.dateformatter stringFromDate:[NSDate date]];
    NSString *topCellName = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text;
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.dateformatter = [[NSDateFormatter alloc] init];
    [self.dateformatter setDateFormat:@"dd-MM-yy"];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDate)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    NSLog(@"Today is: %@", [self.dateformatter stringFromDate:[NSDate date]]);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self configureFetch];
    [self performFetch];
    if(self.frc.fetchedObjects.count <= 0) {
        NSLog(@"No data found!");
        [self addTodayEntry];
        [self performFetch];
        [self.tableView reloadData];
    }

    if([self hasLatestDateBeenCreated]) {
        NSLog(@"Latest entry is todays date, everythings a go.");
    } else {
        NSLog(@"Latest entry is not todays date, attempting to add todays date");
        [self addTodayEntry];
        NSLog(@"Added todays entry.. ");
        [self performSelector:@selector(delayConfirm) withObject:nil afterDelay:0.3];
    }
    

}
-(void)delayConfirm {
    [self.tableView reloadData];
    if([self hasLatestDateBeenCreated]) {
        NSLog(@"Success!");
    } else {
        NSLog(@"ERROR: Database taking longer than usual..");
        [self performSelector:@selector(delayConfirm) withObject:nil afterDelay:0.3];
    }
}
-(void)addTodayEntry {
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
    [newObject setValue:[NSDate date] forKey:@"Date"];
    [cdh backgroundSaveContext];
    [cdh.context refreshObject:newObject mergeChanges:NO];
}

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
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(cell == nil) {
        NSLog(@"Cell is nil");
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    if(self.frc.fetchedObjects) {
        // Workout *workout = [self.frc objectAtIndexPath:indexPath];
       // cell.textLabel.text = [self.dateformatter stringFromDate:workout.Date];
        
        NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
        cell.textLabel.text = [self.dateformatter stringFromDate:[object valueForKey:@"Date"]];
        
        NSString *today = [self.dateformatter stringFromDate:[NSDate date]];
        if([cell.textLabel.text isEqualToString:today]) {
            //UIImage *image = [UIImage imageNamed:@"greenbutton.png"];
            cell.imageView.image = [ThumbnailCreator createThumbnailWithImage:[UIImage imageNamed:@"greenbutton"]];
            NSLog(@"GREEN");
        } else {
          //  UIImage *image = [UIImage imageNamed:@"redbutton.png"];
            cell.imageView.image = [ThumbnailCreator createThumbnailWithImage:[UIImage imageNamed:@"redbutton"]];
            NSLog(@"RED");
        }
    // Configure the cell...
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];
    //NSDictionary *dict = (NSDictionary*)[self.frc objectAtIndexPath:indexPath];
    
    NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
    
    NSArray *retrievedArray = [AppDelegate getWorkouts];
    NSArray *retrievedUnits = [AppDelegate getUnits];
    
    [retrievedArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ (%@): %@", (NSString*)[retrievedArray objectAtIndex:idx], (NSString*)[retrievedUnits objectAtIndex:idx], [object valueForKey:obj]);
    }];

    
    NSString *dateL = [NSString stringWithFormat:@"%@", [self.dateformatter stringFromDate:[object valueForKey:@"Date"]]];
    
    [workoutVC setDateLabelText:dateL];
    
    if([cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:object] error:nil]) {
        [workoutVC sendObject:object.objectID];
    } else {
        NSLog(@"ERROR: NO ID");
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
