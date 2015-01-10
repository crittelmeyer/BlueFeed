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
#import "PostDetailViewController.h"

@interface PostsViewController ()

@end

@implementation PostsViewController

NSArray *feed;
NSString * const API_URL = @"http://bfapp-bfsharing.rhcloud.com";
NSDateFormatter *utcDateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    [self getFeed];
    
    self.postsView.delegate = self;
    self.postsView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeed {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
    
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
        [self.postsView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

#pragma mark -
#pragma mark Table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PostCell *cell = [self.postsView dequeueReusableCellWithIdentifier:@"PostCell"];

    if (feed.count > 0) {
        NSDictionary *post = [feed objectAtIndex:indexPath.row];
        
        //populate post text
        NSString *postText = [post objectForKey:@"postText"];
        cell.postMessageLabel.numberOfLines = 0;
//        cell.postMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.postMessageLabel.text = [postText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //Calculate the expected size based on the font and linebreak mode of your label
//        CGSize maximumLabelSize = CGSizeMake(296,9999);
//        CGSize expectedLabelSize = [cell.postMessageLabel sizeThatFits:maximumLabelSize];
//        
//        //adjust the label the the new height.
//        CGRect newFrame = cell.postMessageLabel.frame;
//        newFrame.size.height = expectedLabelSize.height;
//        [cell.postMessageLabel sizeToFit];


        
        //populate username
        NSString *username = [[post objectForKey:@"postUser"] objectForKey:@"username"];
        cell.usernameLabel.text = username;
        
        //populate timestamp
        NSString *timestampOrig = [post objectForKey:@"createdDate"];
        NSString *timestampFriendly = [self dateDiff:timestampOrig];
        cell.timestampLabel.text = timestampFriendly;
        
        //populate profile pic
        NSString *imageUrl = [API_URL stringByAppendingString:[[post objectForKey:@"postUser"] objectForKey:@"imageUrl"]];
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        cell.authorPic.image = image;
        
        //populate comments button
        NSArray *comments = [post objectForKey:@"comments"];
        NSString *commentsText = [NSString stringWithFormat:@"%lu comments", comments.count];
        [cell.viewComments setTitle:commentsText forState:UIControlStateNormal];
    }
    
    return cell;
}

-(NSString *)dateDiff:(NSString *)origDate {
    
    //convert date string to NSDate
    NSDate *convertedDate = [utcDateFormatter dateFromString:origDate];
    
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
//    } else if (ti < 2629743) {
//        int diff = round(ti / 60 / 60 / 24 / 7);
//        return[NSString stringWithFormat:@"%d weeks ago", diff];
//    } else if (ti < 31536000) {
//        int diff = round(ti / 60 / 60 / 24 / 30);
//        return[NSString stringWithFormat:@"%d months ago", diff];
    } else {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M/d/yy 'at' h:mm a"];
        return [dateFormatter stringFromDate:convertedDate];
    }	
}




@end
