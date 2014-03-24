//
//  WDListsTableViewController.m
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDListsTableViewController.h"
#import "WDItemsViewController.h"
#import "WDListsTableViewCell.h"
#import "WDLogInViewController.h"
#import "WDACL.h"



@interface WDListsTableViewController () <UIAlertViewDelegate, UITableViewDelegate, WDListsTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *lists;

@end

@implementation WDListsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;

    [[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:20.0f]}];
    self.navigationItem.title = @"LISTS";
    [self.tableView registerClass:[WDListsTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
//    [self presentLastVisitedList];
    [self reloadListsForUser:self.user];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)presentLastVisitedList
{
    NSDictionary *savedList = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_VISITED_LIST];
    
    if (savedList)
    {
        WDList *list = [[WDList alloc] initWithName:savedList[LAST_VISITED_LISTNAME] andListID:savedList[LAST_VISITED_LISTID]];
        if ([self listExists:list.listID]) {
            [self performSegueWithIdentifier:ITEMS_SEGUE sender:list];
        }
        else
        {
            [self reloadListsForUser:self.user];
        }
    }
    else
    {
        [self reloadListsForUser:self.user];
    }
}

- (BOOL)listExists:(NSString *)listID
{
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    PFObject *object = [query getObjectWithId:listID];
    if (object) {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)saveList:(NSString *)listName andUser:(PFUser *)user
{
    PFObject *list = [PFObject objectWithClassName:@"List"];
    list[@"Name"] = listName;
    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"Failed to add list %@: %@", listName, error);
        }
        else if (succeeded)
        {
            PFRole *role = [PFRole roleWithName:[list.objectId stringByAppendingString:LIST_ROLE_SUFFIX] acl:[WDACL roleACL]];
            [role.users addObject:user];
            [role saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                {
                    NSLog(@"Failed to create role %@ for list %@: %@", role.name, listName, error);
                }
                else if (succeeded)
                {
                    list.ACL = [WDACL listACL:role];
                    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error)
                        {
                            NSLog(@"Failed to create listACL for list %@: %@", listName, error);
                        }
                    }];
                }
            }];
        }
    }];
}


- (void)reloadListsForUser:(PFUser *)user
{
    PFQuery *queryForLists = [PFQuery queryWithClassName:@"List"];
    [queryForLists findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.lists = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
    
    [self.refreshControl endRefreshing];
}


#pragma mark IBActions


- (IBAction)addListBarButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView *newListAlertView = [[UIAlertView alloc] initWithTitle:@"Enter new list name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [newListAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newListAlertView show];
}

#pragma mark WDListsTableViewCellDelegate
- (void)listDeleted:(WDList *)list
{
    [self deleteItemsForList:list];
    
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    [query getObjectInBackgroundWithId:list.listID block:^(PFObject *list, NSError *error) {
        [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self reloadListsForUser:self.user];
            }
            else if (error) {
                NSLog(@"List delete failed: %@", error);
            }
        }];
    }];     
    
}

-(void)deleteItemsForList:(WDList *)list
{
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"ListID" equalTo:list.listID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object deleteEventually];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *listName = [alertView textFieldAtIndex:0].text;
        [self saveList:listName andUser:self.user];
        [self reloadListsForUser:self.user];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDListsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    PFObject *pfObject = self.lists[indexPath.row];
//    PFACL *listACL = pfObject.ACL;
    WDList *list = [[WDList alloc] initWithName:pfObject[@"Name"] andListID:pfObject.objectId];
    cell.list = list;
    cell.textLabel.text = list.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [[UIColor alloc] initWithRed:198.0/255.0 green:226.0/255.0 blue:255.0/255.0 alpha:1.0];
    [self performSegueWithIdentifier:ITEMS_SEGUE sender:self];
}


//next two methods control cell deletion
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([cell isKindOfClass:[WDListsTableViewCell class]])
        {
            [self listDeleted:((WDListsTableViewCell *)cell).list];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ITEMS_SEGUE]) {
        if ([segue.destinationViewController isKindOfClass:[WDItemsViewController class]]) {
            
            NSIndexPath *path = [self.tableView indexPathForSelectedRow];
            PFObject *pfObject = self.lists[path.row];
            
            WDItemsViewController *targetViewController = segue.destinationViewController;
            targetViewController.list = [[WDList alloc] initWithName:pfObject[@"Name"] andListID:pfObject.objectId];
        }
    }
}


@end
