//
//  LoginResponse.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginResponse.h"

@implementation LoginResponse

@synthesize userId;
@synthesize imageUrl;
@synthesize username;
@synthesize lastActionDate;
@synthesize createdDate;
@synthesize password;

+(RKObjectMapping*)defineLoginResponseMapping   {
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LoginResponse class]];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"userId":   @"userId",
                                                  @"imageUrl":   @"imageUrl",
                                                  @"username":   @"username",
                                                  @"lastActionDate":   @"lastActionDate",
                                                  @"createdDate":   @"createdDate",
                                                  @"password":   @"password"
                                                  }];
    
    
    return mapping;
    
}

@end
