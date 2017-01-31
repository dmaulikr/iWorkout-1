//
//  MainTableViewController.h
//  iWorkout
//
//  Created by Dayan Yonnatan on 06/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@import GoogleMobileAds;

@interface MainTableViewController : UIViewController

// FetchedResultsController
@property (nonatomic, strong) NSFetchedResultsController *frc;
//@property (nonatomic, strong) NSDateFormatter *dateformatter;

// New
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;

@end
