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
#import "Post.h"

@interface PostsViewController ()

@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configureRestKit];
//    [self loadPosts];
    
    self.postsView.delegate = self;
    self.postsView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)configureRestKit {
//    // initialize AFNetworking HTTPClient
//    NSURL *baseURL = [NSURL URLWithString:@"http://bfapp-bfsharing.rhcloud.com/feed"];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
//    
//    // initialize RestKit
//    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
//    
//    // setup object mappings
//    RKObjectMapping *postMapping = [RKObjectMapping mappingForClass:[Post class]];
//    [postMapping addAttributeMappingsFromArray:@[@"name"]];
//    
//    // register mappings with the provider using a response descriptor
//    RKResponseDescriptor *responseDescriptor =
//    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
//                                                 method:RKRequestMethodGET
//                                            pathPattern:@"/feed"
//                                                keyPath:@"response.venues"
//                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
//    
//    [objectManager addResponseDescriptor:responseDescriptor];
//}
//
//- (void)loadPosts {
//    
//}

#pragma mark -
#pragma mark Table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.postsView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    return cell;
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
