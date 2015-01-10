//
//  FeedHeaderCell.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/10/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numNewPostsLabel;
@end
