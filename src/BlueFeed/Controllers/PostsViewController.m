//
//  PostsViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/8/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PostsViewController.h"
#import "PostCell.h"
#import "FeedHeaderCell.h"
#import "PostDetailViewController.h"
#import "NewPostViewController.h"

@interface PostsViewController ()

@end

@implementation PostsViewController

AFHTTPClient *httpClient;
NSArray *feed;
NSString * const API_URL = @"http://bfapp-bfsharing.rhcloud.com";
NSDateFormatter *utcDateFormatter;
UIActivityIndicatorView *spinner;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //prep date formatter
    utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

    //prep http client
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
    
    //prep spinner
    spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    //retrieve feed data
    [self getFeed];
    
    self.postsView.delegate = self;
    self.postsView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeed {
    
    //get NSDate for one month ago to send as filter
    NSDate *now = [NSDate date];
    NSDate *oneMonthAgo = [now dateByAddingTimeInterval:-30*24*60*60];

    NSString *asOfDt = [utcDateFormatter stringFromDate:oneMonthAgo];
    NSDictionary *requestParams = @{@"asOfDt" : asOfDt};
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
        path:@"/feed"
        parameters:requestParams];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //parse response
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        //convert array string to proper json string
        responseString = [NSString stringWithFormat:@"%@ %@ %@", @"{ \"feed\":\n", responseString, @"\n}"];
        NSData *feedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData:feedData options:0 error:nil];
        NSArray *feedUnsorted = [feedDict objectForKey:@"feed"];
        
        //sort by createdDate descending
        NSSortDescriptor *createdDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:createdDateDescriptor];
        feed = [feedUnsorted sortedArrayUsingDescriptors:sortDescriptors];
        
        //now that we have our data, reload the table view
        [spinner stopAnimating];
        [self.postsView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (void)viewWillAppear:(BOOL)animated {
    
    feed = [[NSArray alloc] init];

    [self.postsView reloadData];
    
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [self getFeed];
}

#pragma mark -
#pragma mark Table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feed.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //populate feed header cell
    [self.postsView registerNib:[UINib nibWithNibName:@"FeedHeaderCellView" bundle:nil] forCellReuseIdentifier:@"FeedHeaderCellView"];
    
    FeedHeaderCell *feedHeaderCell = [self.postsView dequeueReusableCellWithIdentifier:@"FeedHeaderCellView"];
    
    //populate feed header image
    NSString *currentUserImageUrlString = [API_URL stringByAppendingString:[self.currentUser objectForKey:@"imageUrl"]];
    NSURL *currentUserImageUrl = [NSURL URLWithString:currentUserImageUrlString];
    NSData *currentUserImageData = [NSData dataWithContentsOfURL:currentUserImageUrl];
    UIImage *currentUserProfileImage = [UIImage imageWithData:currentUserImageData];
    feedHeaderCell.profilePic.image = currentUserProfileImage;
    
    //wire up image to tap event
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentUserImageTapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [feedHeaderCell.profilePic setUserInteractionEnabled:YES];
    [feedHeaderCell.profilePic addGestureRecognizer:singleTap];
    
    //populate feed header username
    feedHeaderCell.usernameLabel.text = [self.currentUser objectForKey:@"username"];
    
    //empty num new posts label
    feedHeaderCell.numNewPostsLabel.text = @"";
    
    if (feed.count > 0) {
        
        if (indexPath.row == 0) {
            
            //count unread posts to display
            NSUInteger unreadPostsCount = 0;
            for (NSUInteger i = 0; i < feed.count; i++) {
                NSDictionary *currentPost = feed[i];
                if ([currentPost objectForKey:@"newPostForUser"] != nil) {
                    unreadPostsCount = unreadPostsCount + 1;
                }
            }
            
            if (unreadPostsCount > 0) {
                feedHeaderCell.numNewPostsLabel.text = [NSString stringWithFormat:@"%lu new posts", unreadPostsCount];
            }
            
            return feedHeaderCell;
        } else {
            PostCell *postCell = [self.postsView dequeueReusableCellWithIdentifier:@"PostCellView"];
            if (!postCell) {
                
                [self.postsView registerNib:[UINib nibWithNibName:@"PostCellView" bundle:nil] forCellReuseIdentifier:@"PostCellView"];
                postCell = [self.postsView dequeueReusableCellWithIdentifier:@"PostCellView"];
            }
            
            NSDictionary *post = [feed objectAtIndex:indexPath.row - 1];
            
            //populate post text
            NSString *postText = [post objectForKey:@"postText"];
            
            postCell.postMessageLabel.text = [postText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
            //populate username
            NSString *username = [[post objectForKey:@"postUser"] objectForKey:@"username"];
            postCell.usernameLabel.text = username;
            
            //populate timestamp
            NSString *timestampOrig = [post objectForKey:@"createdDate"];
            NSString *timestampFriendly = [self dateDiff:timestampOrig];
            postCell.timestampLabel.text = timestampFriendly;
            
            //populate profile pic
            NSString *imageUrl = [API_URL stringByAppendingString:[[post objectForKey:@"postUser"] objectForKey:@"imageUrl"]];
            NSURL *url = [NSURL URLWithString:imageUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *authorPic = [UIImage imageWithData:data];
            postCell.authorPic.image = authorPic;
            
            //populate comments button
            NSArray *comments = [post objectForKey:@"comments"];
            NSString *commentsText = [NSString stringWithFormat:@"%lu comments", comments.count];
            [postCell.viewComments setTitle:commentsText forState:UIControlStateNormal];

            return postCell;
        }
    } else {
        return feedHeaderCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = self.storyboard;
    PostDetailViewController *postDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
    
    NSDictionary *selectedPost = [feed objectAtIndex:indexPath.row - 1];
    
    postDetailViewController.post = selectedPost;
    
    [self.navigationController pushViewController:postDetailViewController animated:YES];
}


-(void)currentUserImageTapDetected {
    
    //prep popup
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Update Profile Pic:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take Photo",
                            @"Select Photo",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self takePhoto];
                    break;
                case 1:
                    [self selectPhoto];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)takePhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

    [picker dismissViewControllerAnimated:YES completion:NULL];

    //upload image
    [self uploadPhoto:chosenImage];
}

-(void)uploadPhoto:(UIImage *)image {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    //prep request
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
        path:[NSString stringWithFormat:@"/user/%@/profilepic", [self.currentUser objectForKey:@"username"]]
        parameters:nil];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSString *contentType = @"application/x-www-form-urlencoded";
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@_pic.jpg\"\r\n", [self.currentUser objectForKey:@"username"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:imageData]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    //prep and start operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //parse response
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Got it! %@", responseString);
        
        //reload table
        [self.postsView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

-(NSString *)dateDiff:(NSString *)origDate {
    
    //convert date string to NSDate
    NSDate *convertedDate = [[utcDateFormatter dateFromString:origDate] dateByAddingTimeInterval:-5*60*60];
    
    //get diff between today and date of post
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;

    //return friendly string depending on time interval
    if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 604800) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M/d/yy 'at' h:mm a"];
        return [dateFormatter stringFromDate:convertedDate];
    }
}

- (IBAction)composeNewPost:(id)sender {

    UIStoryboard *storyBoard = [self storyboard];
    
    NewPostViewController *newPostViewController  = [storyBoard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    
    newPostViewController.username = [self.currentUser objectForKey:@"username"];
    newPostViewController.httpClient = httpClient;
    
    [self presentViewController:newPostViewController animated:YES completion:nil];

    
}

@end
