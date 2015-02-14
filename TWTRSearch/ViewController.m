//
//  ViewController.m
//  TWTRSearch
//
//  Created by Karthikeyan Sreenivasan on 2/12/15.
//  Copyright (c) 2015 Karthikeyan Sreenivasan. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSUInteger, RKRTwitterSearchState)
{
    RKRTwitterSearchStateNone,
    RKRTwitterSearchStateLoading,
    RKRTwitterSearchStateNotFound,
    RKRTwitterSearchStateRefused,
    RKRTwitterSearchStateFailed,
    RKRTwitterSearchStateLoaded
};

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *tweetArray;
@property (nonatomic,assign) RKRTwitterSearchState searchState;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtSearchField.delegate = self;
    self.searchState = RKRTwitterSearchStateNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark CoreData Code

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark Search Twitter Code

- (void)SearchTWTRwithText:(NSString*)textToSearch{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    self.searchState = RKRTwitterSearchStateLoading;
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted == YES) {
            NSArray *arrayofAccounts = [account accountsWithAccountType:accountType];
            
            if([arrayofAccounts count] > 0) {
                
                //Taking only the last account in case of multiple twitter accounts.
                ACAccount *twtrAccount = [arrayofAccounts lastObject];
                
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                
                [parameters setObject:textToSearch forKey:@"q"];
                [parameters setObject:@"popular" forKey:@"result_type"];
                [parameters setObject:@"100" forKey:@"count"];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
                
                posts.account = twtrAccount;
                
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    
                    self.tweetArray = jsonResult[@"statuses"];
                    if ([self.tweetArray count] == 0)
                    {
                        NSArray *errors = jsonResult[@"errors"];
                        if ([errors count])
                        {
                            self.searchState = RKRTwitterSearchStateFailed;
                        }
                        else
                        {
                            self.searchState = RKRTwitterSearchStateNotFound;
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.searchResultTableView reloadData];
                    });
                }];
                
                self.searchState = RKRTwitterSearchStateLoaded;
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
            
            self.searchState = RKRTwitterSearchStateRefused;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchResultTableView reloadData];
            });
        }
    }];
}

- (NSString *)searchMessageForState:(RKRTwitterSearchState)state
{
    switch (state)
    {
        case RKRTwitterSearchStateNone:
            return @"enter text and click search to search twitter.";
            break;
        case RKRTwitterSearchStateLoading:
            return @"Loading...";
            break;
        case RKRTwitterSearchStateNotFound:
            return @"No results found";
            break;
        case RKRTwitterSearchStateRefused:
            return @"Twitter Access Refused";
            break;
        default:
            return @"Not Available";
            break;
    }
}

#pragma mark Connection Code

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.searchState = RKRTwitterSearchStateFailed;

    [self.searchResultTableView reloadData];
}

#pragma mark Table View Data Source Code

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [_tweetArray count];
    return count > 0 ? count : 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID =  @"cellID" ;
    
    NSUInteger count = [self.tweetArray count];
    if ((count == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [self.searchResultTableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.textLabel.text = [self searchMessageForState:self.searchState];
        return cell;
    }
    
    UITableViewCell *cell = [self.searchResultTableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *tweet = (self.tweetArray)[indexPath.row];
    NSDictionary *tweetUserData = [tweet objectForKey:@"user"];
    
    cell.textLabel.text =[NSString stringWithFormat:@"@%@ :\n%@", tweetUserData[@"screen_name"], tweet[@"text"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.searchState == RKRTwitterSearchStateLoaded) {
        // Action sheet style.
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Save Tweet" message:@"Do you want to save this tweet to your phone?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"Do nothing...");
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"Save tweet...");
        }];
        
        [actionSheet addAction:defaultAction];
        [actionSheet addAction:cancelAction];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
        //NSManagedObjectContext *context = [self managedObjectContext];
        
        // Create a new saveTweet
        //NSManagedObject *saveTweet = [NSEntityDescription insertNewObjectForEntityForName:@"SavedTweets" inManagedObjectContext:context];
        //[saveTweet setValue:textFieldMake.text forKey:@"id"];
        //[saveTweet setValue:textFieldModel.text forKey:@"searchText"];
        //[saveTweet setValue:textFieldColor.text forKey:@"tweet"];
    }
}

#pragma mark Search Button Code

- (IBAction)GetTweetsForSearchText:(id)sender {
    
    NSString *encodedQuery = [self.txtSearchField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self SearchTWTRwithText:encodedQuery];
}

#pragma mark MISC

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
