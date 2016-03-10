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

@interface MainTableViewController ()

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateformatter = [[NSDateFormatter alloc] init];
    [self.dateformatter setDateFormat:@"dd-MM-yy"];
    
    NSLog(@"Today is: %@", [self.dateformatter stringFromDate:[NSDate date]]);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self configureFetch];
    [self performFetch];
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
    CoreDataHelper *cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:YES]];
    
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
        // Workout *workout = [self.frc objectAtIndexPath:indexPath];
       // cell.textLabel.text = [self.dateformatter stringFromDate:workout.Date];
        
        NSManagedObject *object = [self.frc objectAtIndexPath:indexPath];
        cell.textLabel.text = [self.dateformatter stringFromDate:[object valueForKey:@"Date"]];

    // Configure the cell...
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];
    NSDictionary *dict = (NSDictionary*)[self.frc objectAtIndexPath:indexPath];
    NSString *dateL = [NSString stringWithFormat:@"%@", [self.dateformatter stringFromDate:[dict valueForKey:@"Date"]]];
    [workoutVC setDateLabelText:dateL];
    [workoutVC sendDict:dict];
    [self.navigationController pushViewController:workoutVC animated:YES];
}
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
