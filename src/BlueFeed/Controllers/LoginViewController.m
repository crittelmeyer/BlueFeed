//
//  LoginViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/6/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (IBAction)forgotBtn:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:admin@bluefeed.com?subject=HELP!&content=I%20forgot%20my%20password!"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.password.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn:) name:@"loggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) name:@"failedLogin" object:nil];
    
//    NSString *username = [self.username.text]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)password
{
    NSString *un = self.username.text;
    NSString *pw = self.password.text;
    [[LoginManager alloc] LoginWithUserName:un password:pw];
    
    return NO;
}

- (void)loggedIn:(NSNotification*) notification {
    [self performSegueWithIdentifier:@"postsViewSegue" sender:self];
}

- (void)failedLogin:(NSNotification*) notification {
    
//    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
//        message:@"This is the message."
//        delegate:self
//        cancelButtonTitle:@"OK"
//        otherButtonTitles:nil];
//    [theAlert show];
    self.badLoginLabel.text = @"bad login. no feed for you.";
}

@end
