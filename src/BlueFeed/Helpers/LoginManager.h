//
//  LoginManager.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKObjectManager.h"
#import "LoginResponse.h"
#import "LoginRequest.h"

@interface LoginManager : NSObject
@property (nonatomic, strong) LoginRequest *dataObject;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) AFHTTPClient *client;
-(void)loginWithUserName:(NSString*)username password:(NSString*)password;
-(void)logout;

@end

