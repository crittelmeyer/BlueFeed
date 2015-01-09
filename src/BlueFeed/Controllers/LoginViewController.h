//
//  LoginViewController.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/6/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *forgotBtn;

- (void)loggedIn;

@end

