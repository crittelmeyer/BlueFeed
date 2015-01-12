//
//  NewPostViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/10/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "NewPostViewController.h"
#import "PostsViewController.h"

@interface NewPostViewController ()

@end

@implementation NewPostViewController

@synthesize username;
@synthesize httpClient;

UIActivityIndicatorView *spinner;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.createPostTextView.editable = YES;
    self.createPostTextView.text = @"";
    
    [self.createPostTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelNewPost:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveNewPost:(id)sender {
    
    [self postMessageToServer];
}

- (void)postMessageToServer {
    
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSString *postText = self.createPostTextView.text;
    NSDictionary *requestParams = @{@"username" : [self username],
                                    @"postText" : postText};
    
    PostsViewController *postsViewController = self.presentingViewController;
    
    NSMutableURLRequest *request = [httpClient
requestWithMethod:@"POST"
                                                            path:@"/post"
                                                      parameters:requestParams];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //parse response
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        //TODO: check response string for errors
        
        
        //stop spinner and close modal
        [spinner stopAnimating];
        [self dismissModalViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
