//
//  ViewController.h
//  TWTRSearch
//
//  Created by Karthikeyan Sreenivasan on 2/12/15.
//  Copyright (c) 2015 Karthikeyan Sreenivasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearchField;

- (IBAction)GetTweetsForSearchText:(id)sender;

@end

