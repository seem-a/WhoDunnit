//
//  WDListMembersViewController.m
//  WhoDunnit
//
//  Created by me on 23/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDListMembersViewController.h"

@interface WDListMembersViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSMutableArray *pendingInvites;
@property (strong, nonatomic) IBOutlet UIView *inviteUserView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *invitationsBarButton;

@end

@implementation WDListMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.members = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.inviteUserView removeFromSuperview];

    [self getListMembers];
    [self getPendingInvites];
    
    [super viewWillAppear:animated];
    
    if (self.invitationsCount > 0) {
        self.invitationsBarButton.title = [[[NSNumber numberWithInt:self.invitationsCount] stringValue] stringByAppendingString:@" Invitations"];
    }
    else
    {
        self.invitationsBarButton.title = @"";
        self.invitationsBarButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Helpers

- (void)getListMembers
{
    NSString *listMembersRoleName = [self.list.listID stringByAppendingString:LIST_ROLE_SUFFIX];
    
    // Get the role
    PFQuery *query = [PFRole query];
    [query whereKey:@"name" equalTo:listMembersRoleName];
    
    PFObject *object = [query getFirstObject];
    
    if (!object)
    {
        NSLog(@"Could not fetch the list members role: %@", listMembersRoleName);
    } else
    {
        PFRole *role = (PFRole *)object;
        PFRelation *userRelation = role.users;
        
        PFQuery *userRelationQuery = [userRelation query];
        NSArray *objects = [userRelationQuery findObjects];
        
        if (objects.count > 0)
        {
            for (NSObject *object in objects)
            {
                PFUser *user = (PFUser *)object;
                [self.members addObject:user.username];
            }
        }
    }
}

//- (void)getPendingInvites_Old
//{
//    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
//    [query whereKey:@"ListID" equalTo:self.list.listID];
//    PFObject *object = [query getFirstObject];
//    self.pendingInvites = (NSArray *)[object objectForKey:USER_EMAIL];
//}

- (void)getPendingInvites
{
    self.pendingInvites = [[NSMutableArray alloc] init];

    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
    [query whereKey:@"ListID" equalTo:self.list.listID];
    NSArray *objects = [query findObjects];
    for (PFObject *object in objects) {
        [self.pendingInvites addObject:object[@"To"]];
    }
}

- (void)inviteUser:(NSString *)emailAddress toList:(WDList *)list
{
    NSString *pushMessage = [NSString stringWithFormat:@"You have been invited to '%@' by %@", list.name, [[PFUser currentUser] username]];

    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"email" equalTo:emailAddress];
    
    // Find devices associated with these users
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:userQuery];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushMessage, @"alert",
                          @"Increment", @"badge", //TODO: remove badge once invite seen
                          [PFUser currentUser].username, @"Sender",
                          list.listID, @"ListID",
                          list.name, @"ListName",
                          nil];

    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];

    [self savePendingInvite:emailAddress];

//    TODO: send email if invitee not an existing user
//    [pushQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!objects || objects.count == 0) {
//            [self sendEmail:emailAddress];
//        }
//    }];
}

//- (void)savePendingInvite_Old:(NSString *)emailAddress
//{
//    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
//    [query whereKey:@"ListID" equalTo:self.list.listID];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (error) {
//            NSLog(@"Failed to retrieve PendingInvites for list %@: %@", self.list.listID, error);
//        }
//        else if (object) {
//            [object addUniqueObject:emailAddress forKey:USER_EMAIL];
//            [object save];
//            
//            self.pendingInvites = (NSMutableArray *)object[USER_EMAIL];
//            [self.tableView reloadData];
//        }
//    }];
//}

- (void) savePendingInvite:(NSString *)emailAddress
{
    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
    [query whereKey:@"ListID" equalTo:self.list.listID];
    [query whereKey:@"To" equalTo:emailAddress];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            if (count == 0) {
                PFObject *invite = [PFObject objectWithClassName:PENDING_INVITES];
                invite[@"ListID"] = self.list.listID;
                invite[@"To"] = emailAddress;
                invite[@"From"] = [PFUser currentUser].username;
                if ([invite save])
                {
                    [self getPendingInvites];
                    [self.tableView reloadData];
                }
            }
            
        } else {
            NSLog(@"Unable to determine if invite to list %@ already sent to %@", self.list.listID, emailAddress);
        }
    }];
}

- (void)sendEmail:(NSString *)emailAddress
{
    //TODO
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.members.count + 1;
    }
    else
    {
        return self.pendingInvites.count + 2;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) cell.textLabel.text = @"MEMBERS OF THIS LIST";
        else cell.textLabel.text = self.members[indexPath.row - 1];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) ;
        else if (indexPath.row == 1) cell.textLabel.text = @"PENDING INVITES";
        else {
                cell.textLabel.text = self.pendingInvites[indexPath.row - 2];
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self inviteUser:[alertView textFieldAtIndex:0].text toList:self.list];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [self.navigationItem setBackBarButtonItem:newBackButton];
}

#pragma mark IBActions

- (IBAction)inviteBarButtonItemPressed:(UIBarButtonItem *)sender
{
    UIAlertView *newListAlertView = [[UIAlertView alloc] initWithTitle:@"Enter email address of user" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
    [newListAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newListAlertView show];
}

@end
