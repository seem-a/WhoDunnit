//
//  WDInvitationsViewController.m
//  WhoDunnit
//
//  Created by me on 29/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDInvitationsViewController.h"
#import "WDInvitationsTableViewCell.h"

@interface WDInvitationsViewController () <UITableViewDelegate, UITableViewDataSource, WDInvitationsTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *invitations;


@end

@implementation WDInvitationsViewController
int invitationsCount;

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
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"INVITATIONS";
    
    self.invitations = [[NSMutableArray alloc] init];
    [self getInvitations];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helpers

-(void) getInvitations
{
    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
    [query whereKey:@"To" equalTo:[PFUser currentUser].email];
    NSArray *objects = [query findObjects];
    for (PFObject *object in objects)
    {
        NSDictionary *invitation = @{@"ListID":object[@"ListID"], @"ListName":object[@"ListName"], @"To":object[@"To"], @"From":object[@"From"]};
        [self.invitations addObject:invitation];
    }
}

-(void)addToRole:(NSDictionary *)invitation
{
    NSString *roleName = [invitation[@"ListID"] stringByAppendingString:LIST_ROLE_SUFFIX];
    
    PFQuery *roleQuery = [PFRole query];
    [roleQuery whereKey:@"name" equalTo:roleName];
    PFObject *object = [roleQuery getFirstObject];
    PFRole * role = (PFRole *)object;
    [role.users addObject:[PFUser currentUser]];
    if (![role save]) {
        NSLog(@"Failed to add user %@ to role: %@", [[PFUser currentUser] username], roleName);
    }
    

}

-(void)deletePendingInvite:(NSDictionary *)invitation
{
    PFQuery *pendingInvitesQuery = [PFQuery queryWithClassName:PENDING_INVITES];
    [pendingInvitesQuery whereKey:@"ListID" equalTo:invitation[@"ListID"]];
    [pendingInvitesQuery whereKey:@"To" equalTo:invitation[@"To"]];
    [pendingInvitesQuery whereKey:@"From" equalTo:invitation[@"From"]];
    [pendingInvitesQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [object deleteEventually];
        }
        else
        {
            NSLog(@"Failed to delete pending invite for list %@ to %@ from %@", invitation[@"ListID"], invitation[@"To"], invitation[@"From"]);
        }
    }];
}


#pragma mark UITableViewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.invitations count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDInvitationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    NSDictionary *invitation = self.invitations[indexPath.row];
    cell.invitationText.text = [NSString stringWithFormat:@"List: %@ From: %@", invitation[@"ListName"], invitation[@"From"]];
    
    return cell;
}


#pragma mark WDInvitationsTableViewCellDelegate

-(void)processInvitation:(NSIndexPath *)indexPath whereInvitationAccepted:(BOOL)accepted
{
    NSDictionary *invitation = self.invitations[indexPath.row];
    [self.invitations removeObjectAtIndex:indexPath.row];
    
    invitationsCount = [self.invitations count];
    if (accepted) [self addToRole:invitation];
    
    [self deletePendingInvite:invitation];

    if (invitationsCount == 0) [self.navigationController popViewControllerAnimated:YES];
    else [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
