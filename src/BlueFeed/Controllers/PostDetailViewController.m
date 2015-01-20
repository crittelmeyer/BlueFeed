//
//  PostDetailViewController.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/10/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "PostDetailViewController.h"
#import "PostDetailHeaderCell.h"
#import "PostDetailCell.h"
#import "PostsViewController.h"

@interface PostDetailViewController ()

@end

@implementation PostDetailViewController

AFHTTPClient *httpClient;
NSDateFormatter *utcDateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postDetailsView.delegate = self;
    self.postDetailsView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *comments = [self.post objectForKey:@"comments"];
    NSLog(@"%@", self.post);
    return comments.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //populate feed header cell
    [self.postDetailsView registerNib:[UINib nibWithNibName:@"PostDetailHeaderCellView" bundle:nil] forCellReuseIdentifier:@"PostDetailHeaderCellView"];
    
    PostDetailHeaderCell *postDetailHeaderCell = [self.postDetailsView dequeueReusableCellWithIdentifier:@"PostDetailHeaderCellView"];
    
    //populate post details header image
    NSDictionary *currentUser = [self.post objectForKey:@"postUser"];
    NSString *currentUserImageUrlString = [API_URL stringByAppendingString:[currentUser objectForKey:@"imageUrl"]];
    NSURL *currentUserImageUrl = [NSURL URLWithString:currentUserImageUrlString];
    NSData *currentUserImageData = [NSData dataWithContentsOfURL:currentUserImageUrl];
    UIImage *currentUserProfileImage = [UIImage imageWithData:currentUserImageData];
    postDetailHeaderCell.authorPic.image = currentUserProfileImage;
    
    //populate post details header username
    postDetailHeaderCell.usernameLabel.text = [currentUser objectForKey:@"username"];
    
    //populate post details header timestamp
    postDetailHeaderCell.timestampLabel.text = [currentUser objectForKey:@"timestamp"];
    
    //populate post details post text
    postDetailHeaderCell.postMessageLabel.text = [[self.post objectForKey:@"postText"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *comments = [self.post objectForKey:@"comments"];
    NSLog(@"%lu", comments.count);
    if (comments.count > 0) {
        if (indexPath.row == 0) {
            return postDetailHeaderCell;
        } else {
            PostDetailCell *postDetailCell = [self.postDetailsView dequeueReusableCellWithIdentifier:@"PostDetailCellView"];
            if (!postDetailCell) {
                [self.postDetailsView registerNib:[UINib nibWithNibName:@"PostDetailCellView" bundle:nil] forCellReuseIdentifier:@"PostDetailCellView"];
                postDetailCell = [self.postDetailsView dequeueReusableCellWithIdentifier:@"PostDetailCellView"];
            }
            
            NSDictionary *comment = [comments objectAtIndex:indexPath.row - 1];
            
            NSString *commentText = [comment objectForKey:@"commentText"];
            
            postDetailCell.commentMessageLabel.text = [commentText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //populate username
            NSDictionary *commentUser = [comment objectForKey:@"commentUser"];
            NSString *username = [commentUser objectForKey:@"username"];
            postDetailCell.usernameLabel.text = username;
            
            //populate timestamp
            NSString *timestampOrig = [comment objectForKey:@"createdDate"];
            NSString *timestampFriendly = [self dateDiff:timestampOrig];
            postDetailCell.timestampLabel.text = timestampFriendly;
            
            //populate profile pic
            NSString *imageUrl = [API_URL stringByAppendingString:[commentUser objectForKey:@"imageUrl"]];
            NSURL *url = [NSURL URLWithString:imageUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *authorPic = [UIImage imageWithData:data];
            postDetailCell.authorPic.image = authorPic;
            
            return postDetailCell;
        }
    } else {
        return postDetailHeaderCell;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
