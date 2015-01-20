//
//  PostDetailViewController.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/10/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *postDetailsView;
@property (weak, nonatomic) NSDictionary *post;

@end
