//
//  SavedViewController.m
//  TWTRSearch
//
//  Created by Karthikeyan Sreenivasan on 2/13/15.
//  Copyright (c) 2015 Karthikeyan Sreenivasan. All rights reserved.
//

#import "SavedViewController.h"

@interface SavedViewController ()

@end

@implementation SavedViewController

#pragma mark Table View Data Source Code

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = 0; //[_tweetArray count];
    return count > 0 ? count : 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID =  @"savedCellID" ;
    
    UITableViewCell *cell = [self.savedTweetTableView dequeueReusableCellWithIdentifier:cellID];
    cell.textLabel.text = @"Sample test";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)SavedDoneButton:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
@end