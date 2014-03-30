//
//  WDItemsTableViewController.m
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDItemsViewController.h"
#import "WDItemsTableViewCell.h"
#import "WDListMembersViewController.h"


@interface WDItemsViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate, WDItemsTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *itemTextField;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *invitationsBarButton;

@end

@implementation WDItemsViewController

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
    
//    [self saveCurentList];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[WDItemsTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    
    //Styling of tableView
//    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:238.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
//    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:193.0/255.0 green:255.0/255.0 blue:193.0/255.0 alpha:1.0];
//    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:191.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0];

    
//    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:198.0/255.0 green:226.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    //pull-to-refresh control
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(reloadItems) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    
    //tab gesture in background
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTextField)];
    [self.view addGestureRecognizer:tap];   
    
    //load data
    [self reloadItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.list.name;
    [self.navigationController setToolbarHidden:NO];
    
    [super viewWillAppear:animated];
    
    if (self.invitationsCount > 0) {
        self.invitationsBarButton.title = [[[NSNumber numberWithInt:self.invitationsCount] stringValue] stringByAppendingString:@" Invitations"];
    }
    else
    {
        self.invitationsBarButton.title = @"";
        self.invitationsBarButton.enabled = NO;
    }

    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helpers

- (void)addNewItem:(NSString *)itemName
{
    PFObject *item = [PFObject objectWithClassName:@"Item"];
    item[@"ListID"] = self.list.listID;
    item[@"Name"] = itemName;
    item[@"Done"] = @NO;
 
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self reloadItems];
        }
        else if (error)
        {
            NSLog(@"Failed to add item %@: %@", item, error);
        }
    }];
}

- (void)reloadItems
{
    PFQuery *queryForItems = [PFQuery queryWithClassName:@"Item"];
    [queryForItems whereKey:@"ListID" equalTo:self.list.listID];

    [queryForItems findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.items = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
 
    [self.refreshControl endRefreshing];
}

- (void) displayListTextField
{
    if (!self.itemTextField) {
        CGRect rect = CGRectMake(0, 500, 330, 45);
        self.itemTextField = [[UITextField alloc] initWithFrame:rect];
        self.itemTextField.placeholder = @"Enter your new item here";
        self.itemTextField.backgroundColor = [UIColor lightGrayColor];
        self.itemTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        self.itemTextField.leftViewMode = UITextFieldViewModeAlways;
        self.itemTextField.delegate = self;
        [self.itemTextField setReturnKeyType:UIReturnKeyDone];
    }
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.contentSize = self.itemTextField.frame.size;
        self.scrollView.delegate = self;
    }
    
    [self.scrollView addSubview:self.itemTextField];
    [self.view addSubview:self.scrollView];
    [self.itemTextField becomeFirstResponder];
    
}

-(void)dismissTextField {
    
    if ([self.scrollView isDescendantOfView:self.view])
    {
        [self.scrollView removeFromSuperview];
    }
}

-(UIColor*)colorForIndex:(NSInteger) index {
    NSUInteger itemCount = self.items.count - 1;
    float val = ((float)index / (float)itemCount) * 0.6;
    return [UIColor colorWithRed:0.8 green:val blue:0.1 alpha:1.0];
}

- (void)handleSwipe
{
    NSLog(@"Swipe detected");
}


-(void)saveCurentList
{
    [[NSUserDefaults standardUserDefaults] setObject:@{LAST_VISITED_LISTID:self.list.listID, LAST_VISITED_LISTNAME:self.list.name} forKey:LAST_VISITED_LIST];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark IBActions

- (IBAction)addItemBarButtonItemPressed:(UIBarButtonItem *)sender
{
    if (![self.scrollView isDescendantOfView:self.view]) {
        [self displayListTextField];
    }
    else
    {
        [self.scrollView removeFromSuperview];
    }
}


- (IBAction)invitationsBarButton:(UIBarButtonItem *)sender {
}

# pragma mark TextField animations

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

//- (void)viewWillAppear:(BOOL)animated {
//    
//    [super viewWillAppear:animated];
//    
//    [self registerForKeyboardNotifications];
//    
//}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint textFieldOrigin = self.itemTextField.frame.origin;
    
    CGFloat textFieldHeight = self.itemTextField.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, textFieldOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, textFieldOrigin.y - visibleRect.size.height + textFieldHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.textLabel.backgroundColor = [UIColor clearColor];
        
    // Configure the cell...

    PFObject *pfObject = self.items[indexPath.row];
    WDItem *item = [[WDItem alloc] initWithText:pfObject[@"Name"] andItemID:pfObject.objectId andListID:pfObject[@"ListID"] andIsDone:[pfObject[@"Done"] boolValue]];
    
    cell.item = item;
    cell.textLabel.text = item.text;
    if (item.IsDone)
    {
        cell.textLabel.attributedText = [self doneItem:item.text];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (NSMutableAttributedString *)doneItem:(NSString *)text
{
    return [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[[UIColor alloc] initWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0], NSStrikethroughStyleAttributeName:@1}];
}

#pragma mark - UITableViewDataDelegate protocol methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.backgroundColor = [self colorForIndex:indexPath.row];
}

#pragma mark UITextFieldDlegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addNewItem:self.itemTextField.text];
    [self.itemTextField resignFirstResponder];
    [self.scrollView removeFromSuperview];
    self.itemTextField = nil;
    return YES;
}

#pragma mark WDItemsTableViewCellDelegate

-(void)itemDeleted:(WDItem *)item {
   
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query getObjectInBackgroundWithId:item.itemID block:^(PFObject *item, NSError *error) {
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self reloadItems];
            }
            else if (error) {
                NSLog(@"Delete failed: %@", error);
            }
        }];
    }];
}

-(void) itemCompleted:(WDItem *)item {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query getObjectInBackgroundWithId:item.itemID block:^(PFObject *item, NSError *error) {
        bool isDone = [item[@"Done"] boolValue];
        item[@"Done"] = [NSNumber numberWithBool:!isDone];
        [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self reloadItems];
            }
            else if (error) {
                NSLog(@"Update failed: %@", error);
            }
        }];
    }];
}


#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LISTMEMBERS_SEGUE])
    {
        if ([segue.destinationViewController isKindOfClass:[WDListMembersViewController class]])
        {
            WDListMembersViewController *targetViewController = segue.destinationViewController;
            targetViewController.list = self.list;
            targetViewController.invitationsCount = self.invitationsCount;
        }
    }
}









@end
