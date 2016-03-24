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
    cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
    dateLabel.text = textOfLabel;
    
    [self setupData];
    
    // test
    [self createButtonOnNav];

}

-(void)createButtonOnNav {
    self.navigationItem.title = dateLabel.text;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addReps)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
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
            countToAdd = [NSNumber numberWithFloat:[alertController.textFields.firstObject.text floatValue]];
        } else {
            countToAdd = [NSNumber numberWithInt:[alertController.textFields.firstObject.text intValue]];
        }
        NSLog(@"Added %@", countToAdd);
        [self addEntry:countToAdd toWorkoutAtIndex:indexPass];
    }];
    [alertController addAction:add];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)addEntry:(NSNumber*)number toWorkoutAtIndex:(NSInteger)index {
    
    [workout setValue:number forKey:[arrayOfWorkouts objectAtIndex:index]];
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
    // TEMP. Must be changed to NSNumber (use IF/ELSE to determine whether INT or FLOAT)
    //NSString *reps = (NSString*);
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ = %@ (%@)", name, reps, unit];
    
    return cell;
}
-(void)unSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"You selected: %@", [arrayOfWorkouts objectAtIndex:indexPath.row]);
    
    [_selectedWorkout setString:[arrayOfWorkouts objectAtIndex:indexPath.row]];
    _selectedIndexPath = indexPath;
    
    /*
    BOOL isFloat = NO;
    NSString *name = [arrayOfWorkouts objectAtIndex:indexPath.row];
    NSString *unit = [arrayOfUnits objectAtIndex:indexPath.row];
    
    if([unit isEqualToString:@"Miles"] || [unit isEqualToString:@"Km"] || [unit isEqualToString:@"Mins"]) {
        isFloat = YES;
    } else {
        isFloat = NO;
    }
    
    if([workout valueForKey:name] == nil) {
        NSLog(@"Data is nil. setting to 1");
        if(isFloat) {
            [workout setValue:@1.0 forKey:name];
        } else {
            [workout setValue:@1 forKey:name];
        }
    } else {
        if(isFloat) {
            float oldRep = [(NSNumber*)[workout valueForKey:name] floatValue];
            oldRep = oldRep + 1.0f;
            [workout setValue:[NSNumber numberWithFloat:oldRep] forKey:name];
            NSLog(@"Incremented float data");
        } else {
            int oldRep = [(NSNumber*)[workout valueForKey:name] intValue];
            oldRep = oldRep + 1;
            [workout setValue:[NSNumber numberWithInt:oldRep] forKey:name];
            NSLog(@"Incremented int data");
        }
    }
    
    [cdh backgroundSaveContext];
    [self.tableView reloadData];
    */
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
