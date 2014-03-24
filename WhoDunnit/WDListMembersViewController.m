//
//  WDListMembersViewController.m
//  WhoDunnit
//
//  Created by me on 23/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDListMembersViewController.h"

@interface WDListMembersViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *members;

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
    
    [self getListMembers];
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
            NSLog(@"Found some users: %d!", objects.count);
            for (NSObject *object in objects)
            {
                PFUser *user = (PFUser *)object;
                [self.members addObject:user.username];
            }
        }
    }
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
        return [self.members count] + 1;
    }
    else
    {
        return 2;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"MEMBERS OF THIS LIST";
        }
        else
        {
            cell.textLabel.text = self.members[indexPath.row - 1];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"PENDING INVITES";
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Invite new user";
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate



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
