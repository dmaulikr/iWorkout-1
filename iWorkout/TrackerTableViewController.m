//
//  TrackerTableViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 26/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "TrackerTableViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ExerciseLister.h"
#import "iWorkout-Swift.h"
#import "ExerciseList+CoreDataClass.h"



@interface TrackerTableViewController ()

@end

@implementation TrackerTableViewController
{
    NSMutableArray *exerciseList;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchExercises];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Workout Tracker";
    
    //[self fetchExercises];
   // [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewBarChartWithTitle:(NSString*)title {
    
    ChartViewController *chartVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChartViewController"];
    
    
    if(![chartVC isDataEmptyWithName:title]) {
    chartVC.navigationItem.title = title;
    [chartVC setTrackerTitle:title];
    [self.navigationController pushViewController:chartVC animated:true];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No data" message:@"Insufficient data for selected workout to load graph." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
        chartVC = nil;
        
    }
    
    
}
-(void)fetchExercises {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    exerciseList = [[NSMutableArray alloc] initWithArray:[ExerciseLister getArrayOfWorkouts:appDelegate.cdh.context]];
    
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
    return exerciseList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    ExerciseList *exercise = exerciseList[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = exercise.name;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ExerciseList *exercise = exerciseList[indexPath.row];
    [self viewBarChartWithTitle:exercise.name];
    
    
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
