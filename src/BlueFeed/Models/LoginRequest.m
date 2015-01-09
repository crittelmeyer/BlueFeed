//
//  LoginRequest.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginRequest.h"
#import "RKObjectManager.h"

@implementation LoginRequest

@synthesize username;
@synthesize password;

+ (RKObjectMapping*)defineLoginRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LoginRequest class]];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"username":   @"username",
                                                  @"password":   @"password",
                                                  }];
    
    return mapping;
}

@end
