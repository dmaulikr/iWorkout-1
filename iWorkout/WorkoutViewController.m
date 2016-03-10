//
//  WorkoutViewController.m
//  iWorkout
//
//  Created by Dayan Yonnatan on 10/03/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

#import "WorkoutViewController.h"
#import "AppDelegate.h"

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController
{
    __block int countOfDict;
    NSDictionary *retrievedDictionary;
    NSString *textOfLabel;
}
@synthesize dateLabel, dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dateLabel.text = textOfLabel;
    
    countOfDict = 0;
    if([[NSFileManager defaultManager] fileExistsAtPath:[AppDelegate getPath]]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[AppDelegate getPath]];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            countOfDict++;
        }];
        NSLog(@"Count: %i", countOfDict);
    }
    
    
    dataDict = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)retrievedDictionary copyItems:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __block int poo = 0;
    [dataDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        poo++;
    }];
    NSLog(@"Poo: %i", poo);
}
-(void)sendDict:(NSDictionary*)dictIn {
    retrievedDictionary = dictIn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDateLabelText:(NSString*)textIn {
    textOfLabel = textIn;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return countOfDict;
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
