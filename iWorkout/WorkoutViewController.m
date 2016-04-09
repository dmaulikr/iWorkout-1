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
   // UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [alertController addAction:cancel];
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
