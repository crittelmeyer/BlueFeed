//
//  LoginRequest.h
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKObjectMapping.h"

@interface LoginRequest : NSObject
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;

+(RKObjectMapping*)defineLoginRequestMapping;

@end
