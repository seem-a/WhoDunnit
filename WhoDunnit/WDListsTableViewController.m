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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *invitationsBarButton;

@end

@implementation WDListsTableViewController
int invitationsCount;

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
    
//    [[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:20.0f], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"YOUR LISTS";
    [self.tableView registerClass:[WDListsTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
//    [self presentLastVisitedList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadUsersLists];

    if (invitationsCount > 0) {
        self.invitationsBarButton.title = [[[NSNumber numberWithInt:invitationsCount] stringValue] stringByAppendingString:@" Invitations"];
    }
    else
    {
        self.invitationsBarButton.title = @"";
        self.invitationsBarButton.enabled = NO;
    }
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
        else [self reloadUsersLists];
    }
    else [self reloadUsersLists];
}

- (BOOL)listExists:(NSString *)listID
{
    PFQuery *query = [PFQuery queryWithClassName:@"List"];
    PFObject *object = [query getObjectWithId:listID];
    if (object) return YES;
    else return NO;
}

- (WDList *)addList:(NSString *)listName forUser:(PFUser *)user
{
    PFObject *list = [PFObject objectWithClassName:@"List"];
    list[@"Name"] = listName;
    if ([list save])
    {
        [self reloadUsersLists];
        
        //
        NSIndexPath *selecteRow = [NSIndexPath indexPathForRow:self.lists.count - 1 inSection:0];
        [self.tableView selectRowAtIndexPath:selecteRow animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:selecteRow];
        
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
        return [[WDList alloc] initWithName:list[@"Name"] andListID:list.objectId];
    }
    NSLog(@"Failed to save list: %@", listName);
    return nil;
}

- (void)deleteList:(WDList *)list
{
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"List" objectId:list.listID];
    if ([object delete]) [self reloadUsersLists];
    else NSLog(@"Failed to delete list: %@", list.name);
}

-(void)deleteItems:(WDList *)list
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

- (void)leaveRole:(PFRole *)role
{
    [role.users removeObject:self.user];
    [role save];
}

-(void)deletePendingInvites:(WDList *)list
{
    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
    [query whereKey:@"ListID" equalTo:list.listID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Failed to retrieve PendingInvites for list %@: %@", list.listID, error);
        }
        else if (object) {
            [object deleteEventually];
        }
    }];
 }

-(BOOL)IsLastMember:(PFRole *)role
{
    PFQuery *usersQuery = [role.users query];
    if ([[usersQuery findObjects] count] > 1) return NO;
    else return YES;
}

- (void)reloadUsersLists
{
    PFQuery *queryForLists = [PFQuery queryWithClassName:@"List"];
    NSArray *pfObjects = [queryForLists findObjects];
    self.lists = [pfObjects mutableCopy];
    [self.tableView reloadData];
}


#pragma mark IBActions


- (IBAction)addListBarButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView *newListAlertView = [[UIAlertView alloc] initWithTitle:@"Enter new list name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [newListAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newListAlertView show];
}

- (IBAction)logoutBarButtonItemPressed:(UIBarButtonItem *)sender
{
    NSString *currentUsername = [[PFUser currentUser] username];
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Logout %@?", currentUsername] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
}

- (IBAction)invitationBarButtonPressed:(UIBarButtonItem *)sender {
}

#pragma mark WDListsTableViewCellDelegate
- (void)leaveList:(WDList *)list
{
    NSString *roleName = [list.listID stringByAppendingString:LIST_ROLE_SUFFIX];
    
    PFQuery *roleQuery = [PFRole query];
    [roleQuery whereKey:@"name" equalTo:roleName];
    PFRole *role = (PFRole *)[roleQuery getFirstObject];
    
    if ([self IsLastMember:role]) {
        [self deleteList:list];
        [self deleteItems:list];
        [self deletePendingInvites:list];
        [role deleteEventually];
    }
    else
    {
        [self leaveRole:role];
    }
    [self.tableView reloadData];

}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString: @"Enter new list name"]) {
        if (buttonIndex == 1) {
            NSString *listName = [alertView textFieldAtIndex:0].text;
            [self addList:listName forUser:self.user];
//            [self reloadUsersLists];
        }
    }
    else if ([alertView.title hasPrefix:@"Logout"])
    {
        if (buttonIndex == 1) {
            [PFUser logOut];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    WDList *list = [[WDList alloc] initWithName:pfObject[@"Name"] andListID:pfObject.objectId];
    cell.list = list;
    cell.textLabel.text = list.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor lightTextColor];
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
            [self leaveList:((WDListsTableViewCell *)cell).list];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Leave";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    

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
