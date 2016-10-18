//
//  ViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 29/02/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) IBOutlet UILabel *startLabel;


// Testing dynamic animator.. Leaving these unavailable for now.
#warning Get this UIButton either connected or removed.
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
//@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

