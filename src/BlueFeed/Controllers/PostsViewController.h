//
//  PostsViewController.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/8/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *postsView;
@property (weak, nonatomic) NSDictionary *currentUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeBtn;

-(void)reloadPostsView;

extern NSString * const API_URL;

@end
