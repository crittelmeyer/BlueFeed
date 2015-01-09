//
//  LoginResponse.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKObjectMapping.h"

@interface LoginResponse : NSObject
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* lastActionDate;
@property (nonatomic, strong) NSString* createdDate;
@property (nonatomic, strong) NSString* password;

+(RKObjectMapping*)defineLoginResponseMapping;

@end
