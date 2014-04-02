//
//  WDSignUpViewController.m
//  WhoDunnit
//
//  Created by me on 22/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDSignUpViewController.h"

@interface WDSignUpViewController ()

@end

@implementation WDSignUpViewController

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
    
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];
    self.signUpView.backgroundColor = indianred;
    [self.signUpView.logo addSubview:[self getAppTitle]];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
   
    
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];
    UIFont * labelFont = [UIFont fontWithName:@"Helvetica-Light" size:20];
    NSShadow *shadow = [[NSShadow alloc] init];
    
    CGRect passwordFieldFrame = self.signUpView.passwordField.frame;
    [self.signUpView.passwordField setFrame:CGRectMake(passwordFieldFrame.origin.x, passwordFieldFrame.origin.y + 5.0, passwordFieldFrame.size.width, passwordFieldFrame.size.height)];

    
    CGRect emailFieldFrame = self.signUpView.emailField.frame;
    [self.signUpView.emailField setFrame:CGRectMake(emailFieldFrame.origin.x, emailFieldFrame.origin.y + 10.0, emailFieldFrame.size.width, emailFieldFrame.size.height)];

    CGRect signUpButtonFrame = self.signUpView.signUpButton.frame;
    [self.signUpView.signUpButton setFrame:CGRectMake(signUpButtonFrame.origin.x, signUpButtonFrame.origin.y + 5.0, signUpButtonFrame.size.width, signUpButtonFrame.size.height)];
    
    
    NSAttributedString *usernameAttributedString =
    [[NSAttributedString alloc] initWithString:@"Username"                                                                                   attributes:@{                                                                                                NSFontAttributeName: labelFont,                                                                                            NSForegroundColorAttributeName : [UIColor lightTextColor],                                                                                                NSShadowAttributeName : shadow }];
    
    
    self.signUpView.usernameField.attributedPlaceholder = usernameAttributedString;
    self.signUpView.usernameField.textColor = indianred;
    self.signUpView.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.signUpView.usernameField.layer.borderColor = [indianred CGColor];
    self.signUpView.usernameField.layer.borderWidth = 1.5;
    self.signUpView.usernameField.layer.cornerRadius = 7.0f;
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    
    
    NSAttributedString *passwordAttributedString =
    [[NSAttributedString alloc] initWithString:@"Password"                                                                                   attributes:@{                                                                                                NSFontAttributeName: labelFont,                                                                                            NSForegroundColorAttributeName : [UIColor lightTextColor],                                                                                                NSShadowAttributeName : shadow }];
    
    self.signUpView.passwordField.attributedPlaceholder = passwordAttributedString;
    self.signUpView.passwordField.textColor = indianred;
    self.signUpView.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.signUpView.passwordField.layer.borderColor = [indianred CGColor];
    self.signUpView.passwordField.layer.borderWidth = 1.5;
    self.signUpView.passwordField.layer.cornerRadius = 7.0f;
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    
    
    
    NSAttributedString *emailAttributedString =
    [[NSAttributedString alloc] initWithString:@"Email"                                                                                   attributes:@{                                                                                                NSFontAttributeName: labelFont,                                                                                            NSForegroundColorAttributeName : [UIColor lightTextColor],                                                                                                NSShadowAttributeName : shadow }];
    
    self.signUpView.emailField.attributedPlaceholder = emailAttributedString;
    self.signUpView.emailField.textColor = indianred;
    self.signUpView.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.signUpView.emailField.layer.borderColor = [indianred CGColor];
    self.signUpView.emailField.layer.borderWidth = 1.5;
    self.signUpView.emailField.layer.cornerRadius = 7.0f;
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *) getAppTitle
{
    UIColor *indianred = [UIColor colorWithRed:176.0/255 green:23.0/255.0 blue:31.0/255 alpha:1.0];
    
    
    NSAttributedString *attributedString =
    [[NSAttributedString alloc] initWithString:@"Tick-it"                                                                                   attributes:@{                                                                                                NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:37],                                                                                            NSForegroundColorAttributeName : [UIColor whiteColor],                                                                                                NSShadowAttributeName : [[NSShadow alloc] init] }];
    
    CGRect prevFrame = self.signUpView.logo.frame;
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width + 15.0, prevFrame.size.height + 10.0)];
    appTitle.backgroundColor = indianred;
    appTitle.textColor = [UIColor whiteColor];
    appTitle.attributedText = attributedString;
    
    return appTitle;
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
