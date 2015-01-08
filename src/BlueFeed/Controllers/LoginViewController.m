//
//  LoginViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/6/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
- (IBAction)forgotBtn:(id)sender {
//    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
//        message:@"This is the message."
//        delegate:self
//        cancelButtonTitle:@"OK"
//        otherButtonTitles:nil];
//    [theAlert show];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:admin@bluefeed.com?subject=HELP!&content=I%20forgot%20my%20password!"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.password.delegate = self;
    
//    NSString *username = [self.username.text]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)password
{
    //TODO: Login
    
    [self performSegueWithIdentifier:@"postsViewSegue" sender:self];
    
    return YES;
}

@end
