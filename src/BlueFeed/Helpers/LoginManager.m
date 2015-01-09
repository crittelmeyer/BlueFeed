//
//  LoginManager.m
//  BlueFeed
//
//  Created by Chris Rittelmeyer on 1/9/15.
//  Copyright (c) 2015 Chris Rittelmeyer. All rights reserved.
//

#import "LoginManager.h"
#import "RKMIMETypeSerialization.h"
#import "RKLog.h"
#import "LoginRequest.h"
#import "LoginViewController.h"


@implementation LoginManager

-(void)LoginWithUserName:(NSString *)username password:(NSString*)password {
    
    LoginRequest *dataObject = [[LoginRequest alloc] init];
    [dataObject setUsername:username];
    [dataObject setPassword:password];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://bfapp-bfsharing.rhcloud.com/login"];
    
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *requestMapping =  [[LoginRequest defineLoginRequestMapping] inverseMapping];
    
    [objectManager addRequestDescriptor: [RKRequestDescriptor
                                          requestDescriptorWithMapping:requestMapping objectClass:[LoginRequest class] rootKeyPath:nil
                                          ]];
    // what to print
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("Restkit/Network", RKLogLevelDebug);
    
    RKObjectMapping *responseMapping = [LoginResponse defineLoginResponseMapping];
    
    [objectManager addResponseDescriptor:[RKResponseDescriptor
                                          responseDescriptorWithMapping:responseMapping method:RKRequestMethodAny pathPattern:@"" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
                                          
                                          ]];
    
    [objectManager setRequestSerializationMIMEType: RKMIMETypeJSON];
    
    [objectManager postObject:dataObject path:@"" parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          NSLog(@"It Worked: %@", [mappingResult array]);
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedIn" object:nil];
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"It Failed: %@", error);
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"failedLogin" object:nil];
                      }];
}

@end
