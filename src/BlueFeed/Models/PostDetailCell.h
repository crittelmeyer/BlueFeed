//
//  PostDetailCell.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/8/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *authorPic;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentMessageLabel;

@end
