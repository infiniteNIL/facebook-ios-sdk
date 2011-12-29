//
//  SFFacebookRequest.m
//  facebook-ios-sdk
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFFacebookRequest.h"
#import "Facebook.h"

@implementation SFFacebookRequest

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    self = [self init];
    if (self) {
        _successBlock = [success copy];
        _failureBlock = [failure copy];
        [facebook requestWithGraphPath:graphPath andDelegate:self];
    }
    return self;
}

+ (SFFacebookRequest *)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    return [[[SFFacebookRequest alloc] initWithFacebook:facebook graphPath:graphPath success:success failure:failure] autorelease];
}

#pragma mark - FBRequestDelegate

/**
 * Called just before the request is sent to the server.
 */
//- (void)requestLoading:(FBRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
//- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error description]);
    
    _failureBlock(error);
    [_failureBlock release];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	_successBlock(result);
    [_successBlock release];
}

@end
