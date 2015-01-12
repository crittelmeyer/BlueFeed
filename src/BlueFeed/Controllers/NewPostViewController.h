//
//  NewPostViewController.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/10/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface NewPostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *createPostTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelNewPostBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveNewPostBtn;

@property NSString *username;
@property AFHTTPClient *httpClient;

@end
