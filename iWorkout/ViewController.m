//
//  ViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "ViewController.h"
#import "SetupViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL DBFileExists;
}
#pragma mark - VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DBFileExists = NO;
    
    self.startLabel.text = @"";
    
    [self performSelector:@selector(loadWorkouts) withObject:nil afterDelay:0.5];
    //[self loadWorkouts];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - SETUP
-(void)loadWorkouts {
    
    if(DBFileExists) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData)];
            [self.view addGestureRecognizer:self.tapGestureRecognizer];
        });
        self.startLabel.text = @"Tap to Start";
    } else {
       // [self performSegueWithIdentifier:@"presentSetupView" sender:nil];
        //[self.presentingViewController performSegueWithIdentifier:@"presentSetupView" sender:nil];
        
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
