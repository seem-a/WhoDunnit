//
//  WDLogInViewController.m
//  WhoDunnit
//
//  Created by me on 22/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WDLogInViewController.h"
#import "WDSignUpViewController.h"
#import "WDListsTableViewController.h"

@interface WDLogInViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation WDLogInViewController
int invitationsCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.view.backgroundColor = [UIColor grayColor];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES];
    
    self.delegate = self;
    
    WDSignUpViewController *signUpViewController = [[WDSignUpViewController alloc] init];
    signUpViewController.delegate = self;
    signUpViewController.fields = PFSignUpFieldsDefault;
    self.signUpController = signUpViewController;

    if ([PFUser currentUser])
    {
        [self presentListsViewController:[PFUser currentUser]];
    }
}

- (void)viewDidDisappear: (BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO];

    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
//    UIColor *dodgerBlue1 = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
//    UIColor *seagreen4 = [UIColor colorWithRed:46.0/255.0 green:139.0/255.0 blue:87.0/255.0 alpha:1.0];
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];
//    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WhoDunnit.png"]];
//    self.logInView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:201.0/255.0 blue:87.0/255.0 alpha:1.0]; //emeraldgreen
//    self.logInView.backgroundColor = [UIColor colorWithRed:61.0/255.0 green:145.0/255.0 blue:64.0/255.0 alpha:1.0]; //cobaltgreen
    self.logInView.backgroundColor = indianred;
    self.logInView.dismissButton.hidden = YES;

    [self.logInView.logo addSubview:[self getAppTitle]];
    
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    UIColor *dodgerBlue1 = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
//    UIColor *slateGray1 = [UIColor colorWithRed:198.0/255.0 green:226.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];
    UIFont * labelFont = [UIFont fontWithName:@"Helvetica-Light" size:20];
    NSShadow *shadow = [[NSShadow alloc] init];

    CGRect passwordFieldFrame = self.logInView.passwordField.frame;
    [self.logInView.passwordField setFrame:CGRectMake(passwordFieldFrame.origin.x, passwordFieldFrame.origin.y + 5.0, passwordFieldFrame.size.width, passwordFieldFrame.size.height)];
    
    CGRect loginButtonFrame = self.logInView.logInButton.frame;
    [self.logInView.logInButton setFrame:CGRectMake(loginButtonFrame.origin.x, loginButtonFrame.origin.y + 5.0, loginButtonFrame.size.width, loginButtonFrame.size.height)];
    
    
    NSAttributedString *usernameAttributedString =
    [[NSAttributedString alloc] initWithString:@"Username"                                                                                   attributes:@{                                                                                                NSFontAttributeName: labelFont,                                                                                            NSForegroundColorAttributeName : [UIColor lightTextColor],                                                                                                NSShadowAttributeName : shadow }];
    
    
    self.logInView.usernameField.attributedPlaceholder = usernameAttributedString;
    self.logInView.usernameField.textColor = indianred;
    self.logInView.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.logInView.usernameField.layer.borderColor = [indianred CGColor];
    self.logInView.usernameField.layer.borderWidth = 1.5;
    self.logInView.usernameField.layer.cornerRadius = 7.0f;
    [self.logInView.usernameField setBackgroundColor:[UIColor whiteColor]];
    
  
    NSAttributedString *passwordAttributedString =
    [[NSAttributedString alloc] initWithString:@"Password"                                                                                   attributes:@{                                                                                                NSFontAttributeName: labelFont,                                                                                            NSForegroundColorAttributeName : [UIColor lightTextColor],                                                                                                NSShadowAttributeName : shadow }];
    
    self.logInView.passwordField.attributedPlaceholder = passwordAttributedString;
    self.logInView.passwordField.textColor = indianred;
    self.logInView.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.logInView.passwordField.layer.borderColor = [indianred CGColor];
    self.logInView.passwordField.layer.borderWidth = 1.5;
    self.logInView.passwordField.layer.cornerRadius = 7.0f;
    [self.logInView.passwordField setBackgroundColor:[UIColor whiteColor]];
    

    
    [self.logInView.logInButton setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal|UIControlStateSelected];
//    [self.logInView.logInButton setImage:[[UIImage alloc] init] forState:UIControlStateNormal | UIControlStateSelected];
//    [self.logInView.logInButton setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal | UIControlStateSelected];
    
//     self.logInView.passwordForgottenButton.hidden = YES;

}

- (UILabel *) getAppTitle
{
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];

    
    NSAttributedString *attributedString =
    [[NSAttributedString alloc] initWithString:@"Tick-it"                                                                                   attributes:@{                                                                                                NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:37],                                                                                            NSForegroundColorAttributeName : [UIColor whiteColor],                                                                                                NSShadowAttributeName : [[NSShadow alloc] init] }];
    
    CGRect prevFrame = self.logInView.logo.frame;
//    NSLog(@"x: %f, y: %f, width: %f, height: %f", prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width, prevFrame.size.height);
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width + 15.0, prevFrame.size.height + 10.0)];
    appTitle.backgroundColor = indianred;
    appTitle.textColor = [UIColor whiteColor];
    appTitle.attributedText = attributedString;
    
    return appTitle;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Please fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {    
    [self presentListsViewController:user];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...%@", error);
    [[[UIAlertView alloc] initWithTitle:@"Account Error" message:@"The username and password combination is incorrect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[WDLogInViewController class]]) {
        WDLogInViewController *loginViewController = (WDLogInViewController *)segue.destinationViewController;
        loginViewController.delegate = self;
        
        WDSignUpViewController *signUpViewController = [[WDSignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault;
        loginViewController.signUpController = signUpViewController;
    }
    else if ([segue.destinationViewController isKindOfClass:[WDListsTableViewController class]]) {
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation[@"user"] = [PFUser currentUser];
        [currentInstallation saveInBackground];
        
        WDListsTableViewController *listsViewController = (WDListsTableViewController *)segue.destinationViewController;
        listsViewController.user = [PFUser currentUser];

        invitationsCount = [self getInvitationsCount];
        [self.navigationController setToolbarHidden:NO];
    }
}

- (void) presentListsViewController:(PFUser *)user
{
    [self performSegueWithIdentifier:@"Lists Segue" sender:self];
}

#pragma mark Helpers

- (int)getInvitationsCount
{
    PFQuery *query = [PFQuery queryWithClassName:PENDING_INVITES];
    [query whereKey:@"To" equalTo:[PFUser currentUser].email];
    return [query countObjects];
}

@end
