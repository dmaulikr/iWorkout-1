//
//  SettingsTableViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 25/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIPickerView *dateformatPicker;

@end
