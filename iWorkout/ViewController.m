//
//  ViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "ViewController.h"
#import "SetupViewController.h"
#import "AppDelegate.h"
#import "MainTableViewController.h"
#import "Workout.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL DBFileExists;
}

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
#pragma mark - VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    /*
    DBFileExists = NO;
    
    self.startLabel.text = @"";
    
    [self performSelector:@selector(loadWorkouts) withObject:nil afterDelay:0.2];
    */
    
    
    /*
    if([self setupDataExists]) {
        [self readyToStart:YES];
    } else {
        [self readyToStart:NO];
    }*/
    //[self loadWorkouts];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}/*
-(NSManagedObjectModel *)_model {
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    
    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
    
    [entity setName:@"Workout"];
    [entity setManagedObjectClassName:@"Workout"];
    
    NSPropertyDescription *property = [[NSPropertyDescription alloc] init];
    
    //[entity setProperties:[self setupModelWithArray:ARRAY]];
    
    return model;
}*/
/*
-(NSAttributeType)getAttributeType:(NSString*)infoD {
    if([infoD isEqualToString:@"Reps"]) {
        return NSInteger16AttributeType;
    } else if([infoD isEqualToString:@"Mins"] || [infoD isEqualToString:@"Km"] || [infoD isEqualToString:@"Miles"]) {
        return NSFloatAttributeType;
    }
    NSLog(@"ERROR!! Unable to match attribute!");
    return NAN;
}
-(NSMutableArray*)setupModelWithArray:(NSArray*)arrayModel {
    NSMutableArray *properties = [NSMutableArray new];
    
    NSAttributeDescription *dateAtt = [[NSAttributeDescription alloc] init];
    [dateAtt setName:@"Date"];
    [dateAtt setAttributeType:NSDateAttributeType];
    [dateAtt setOptional:NO];
    [properties addObject:dateAtt];
    
    [arrayModel enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [obj valueForKey:@"WorkoutName"];
        NSString *unit = [obj valueForKey:@"UnitOfMeasurement"];
        
        NSAttributeDescription *attribute = [[NSAttributeDescription alloc] init];
        [attribute setName:name];
        [attribute setAttributeType:[self getAttributeType:unit]];
        [attribute setOptional:YES];
        [attribute setDefaultValue:0];
        [properties addObject:attribute];
    }];
    return properties;
    
}*/
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.class != [SetupViewController class]) {
    if([self setupDataExists]) {
        NSString *setupPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Setup.plist"];
        NSLog(@"Found setup data!");
        NSArray *retrievedData = [[NSArray alloc] initWithContentsOfFile:setupPath];
        
        [retrievedData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Name: %@  & Unit: %@", [obj valueForKey:@"WorkoutName"], [obj valueForKey:@"UnitOfMeasurement"]);
        }];
        [self readyToStart:YES];
    } else {
        NSLog(@"No data found!");
        [self readyToStart:NO];
    }
    }
    
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - SETUP
-(BOOL)setupDataExists {
    int i = 0;
    NSString *setupPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Setup.plist"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"SetupComplete"] boolValue]) {
        i++;
        if([[NSFileManager defaultManager] fileExistsAtPath:setupPath]) {
            NSLog(@"Setup has been set up fully!");
            return YES;
        }
    }
    if(i == 1) {
        NSLog(@"ERROR: Found plist file but not UserDefaults data");
    }
    return NO;
}
-(void)loadWorkouts {
    /*
    if([self setupDataExists]) {
        DBFileExists = YES;
    }*/
    
    if(DBFileExists) {
        [self readyToStart:YES];
    } else {
        [self readyToStart:NO];
    }
}
-(void)readyToStart:(BOOL)startBool {
    if(startBool) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
        self.startLabel.text = @"Tap to Start";
    } else {
        self.startLabel.text = @"Tap to Setup";
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startSetup)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    }
    
}

-(void)startSetup {
    // Display setup
    SetupViewController *setupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SetupViewController"];
    
    setupVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:setupVC animated:YES completion:nil];
    
}
-(void)loadData {
    // Load DB
    
    NSLog(@"Setup is: %@", [AppDelegate isSetupComplete] ? @"READY" : @"NOT READY");
    if([AppDelegate isSetupComplete]) {
        CoreDataHelper *cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
        
        /*
        Workout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:cdh.context];
        workout.date = [NSDate date];
        
        [cdh backgroundSaveContext];*/
        
        
        // Initialize the presenting view
        MainTableViewController *mainTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTableViewController"];
        [self.navigationController pushViewController:mainTVC animated:YES];
        
    }
    
}

-(void)tapGesture {
    NSLog(@"Tap");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
