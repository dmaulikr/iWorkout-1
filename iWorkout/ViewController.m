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

#define DebugMode 0
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
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    BOOL isAutoLockOn = [[[NSUserDefaults standardUserDefaults] valueForKey:@"DisableAutoLock"] boolValue];
    
    [appDelegate setAutoLock:isAutoLockOn];
    
    /*
    CGPoint oldPositionOfButton = self.settingsButton.frame.origin;
    [self testDynamicsWithOldPos:oldPositionOfButton];
#warning The settings button isnt returning to proper position. Check that out
    */
    
    
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
    
    
}

-(void)testDynamicsWithOldPos:(CGPoint)position {
    __block float width, height;
    width = self.settingsButton.frame.size.width;
    height = self.settingsButton.frame.size.height;
    
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.settingsButton]];
    
    //[gravity setGravityDirection:CGVectorMake(0.0f, 0.1f)];
    
    [self.dynamicAnimator addBehavior:gravity];
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.settingsButton]];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    [self.dynamicAnimator addBehavior:collision];
    
    
    UISnapBehavior *snapBack = [[UISnapBehavior alloc] initWithItem:self.settingsButton snapToPoint:position];
    [snapBack setDamping:1.0f];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dynamicAnimator addBehavior:snapBack];
        //[self.settingsButton setFrame:CGRectMake(position.x, position.y, width, height)];
    });
    
    //self.settingsButton.frame.origin = position;
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.class != [SetupViewController class]) {
    if([self setupDataExists]) {
        if(DebugMode) {
            NSLog(@"Found setup data!");
        }
        [self readyToStart:YES];
    } else {
        if(DebugMode) {
            NSLog(@"No data found!");
        }
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
            if(DebugMode) {
                NSLog(@"Setup has been set up fully!");
            }
            return YES;
        }
    }
    if(i == 1) {
        if(DebugMode) {
            NSLog(@"ERROR: Found plist file but not UserDefaults data");
        }
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
    if(DebugMode) {
        NSLog(@"Setup is: %@", [AppDelegate isSetupComplete] ? @"READY" : @"NOT READY");
    }
    if([AppDelegate isSetupComplete]) {
        // Load DB
        //CoreDataHelper *cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] cdh];
        
        [self presentMainView];
    } else {
        if(DebugMode) {
            NSLog(@"ERROR: Setup isnt complete.");
        }
    }
}
-(void)presentMainView {
    // Initialize the presenting view
    MainTableViewController *mainTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTableViewController"];
    
    [self.navigationController pushViewController:mainTVC animated:YES];
}
/*
-(void)tapGesture {
    NSLog(@"Tap");
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)prefersStatusBarHidden {
    return YES;
}


@end
