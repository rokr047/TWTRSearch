//
//  SavedViewController.h
//  TWTRSearch
//
//  Created by Karthikeyan Sreenivasan on 2/13/15.
//  Copyright (c) 2015 Karthikeyan Sreenivasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)SavedDoneButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *savedTweetTableView;

@end
