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

-(void)loginWithUserName:(NSString *)username password:(NSString*)password {
    
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

    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("Restkit/Network", RKLogLevelDebug);
    
    RKObjectMapping *responseMapping = [LoginResponse defineLoginResponseMapping];
    
    [objectManager addResponseDescriptor:[RKResponseDescriptor
            responseDescriptorWithMapping:responseMapping
            method:RKRequestMethodAny
            pathPattern:@""
            keyPath:nil
            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
     ];
    
    [objectManager setRequestSerializationMIMEType: RKMIMETypeJSON];
    
    [objectManager postObject:dataObject path:@"" parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            LoginResponse *response = [mappingResult firstObject];
            NSLog(@"It Worked: logged in as %@", [response username]);
            
            NSDictionary *userDict = @{@"username": [response username],
                                       @"imageUrl": [response imageUrl]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedIn"
                object:nil
                userInfo:userDict
            ];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"It Failed: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedLogin" object:nil];
        }
     ];
}

-(void)logout {
    
    NSURL *baseURL = [NSURL URLWithString:@"http://bfapp-bfsharing.rhcloud.com/logout"];
    
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:baseURL];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@""
                                                      parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

@end
