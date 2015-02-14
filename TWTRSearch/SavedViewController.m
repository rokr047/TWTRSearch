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

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // here we get the cars from the persistent data store (or the database)
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SavedTweets"];
    self.savedTweets = [[moc  executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.savedTweetTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Code

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.savedTweets count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.savedTweets count] < 1) {
        static NSString *cellID =  @"savedCellID" ;
        UITableViewCell *cell = [self.savedTweetTableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        [cell.textLabel setText:@"You have not saved any tweets yet."];
        return cell;
    }
    
    static NSString *cellID =  @"savedCellID" ;
    UITableViewCell *cell = [self.savedTweetTableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSManagedObject *tweet = [self.savedTweets objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"@%@:\n%@\n--\nsearch term : %@", [tweet valueForKey:@"screenName"], [tweet valueForKey:@"tweet"], [tweet valueForKey:@"searchText"]]];
    
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)SavedDoneButton:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [context deleteObject:[self.savedTweets objectAtIndex:indexPath.row]];
        
        // invode the save method to commit the change
        NSError *error = nil;
        // Save the context
        if (![context save:&error]) {
            NSLog(@"Save Failed! %@ %@", error, [error localizedDescription]);
        }
        
        // Remove car from table view
        [self.savedTweets removeObjectAtIndex:indexPath.row];
        [self.savedTweetTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

@end