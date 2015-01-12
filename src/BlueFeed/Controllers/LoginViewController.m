//
//  LoginViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/6/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginManager.h"
#import "PostsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

NSDictionary *currentUser;
BOOL hasLoggedIn;
LoginManager *loginManager;

- (IBAction)forgotBtn:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:admin@bluefeed.com?subject=HELP!&content=I%20forgot%20my%20password!"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.password.delegate = self;
    
    hasLoggedIn = NO;
    
    loginManager = [LoginManager alloc];
    
    [self.username becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn:) name:@"loggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) name:@"failedLogin" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Sign In";
    
    if (hasLoggedIn) {
        [loginManager logout];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)password
{
    NSString *un = self.username.text;
    NSString *pw = self.password.text;

    [loginManager loginWithUserName:un password:pw];
    
    return NO;
}

- (void)loggedIn:(NSNotification*) notification {

    //store user info
    currentUser = @{@"username": [notification.userInfo objectForKey:@"username"],
                    @"imageUrl": [notification.userInfo objectForKey:@"imageUrl"]
                    };
    
    self.navigationItem.title = @"Sign Out";
    
    hasLoggedIn = YES;
    
    //segue to feed view
    [self performSegueWithIdentifier:@"postsViewSegue" sender:self];
}

- (void)failedLogin:(NSNotification*) notification {
    self.badLoginLabel.text = @"bad login. no feed for you.";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"postsViewSegue"]) {
        
        // Get destination view
        PostsViewController *postsViewController = [segue destinationViewController];
        
        postsViewController.currentUser = currentUser;
    }
}

@end
