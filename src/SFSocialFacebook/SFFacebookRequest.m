//
//  SFFacebookRequest.m
//  facebook-ios-sdk
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFFacebookRequest.h"
#import "Facebook.h"
#import "SFUtil.h"
#import "SFSocialFacebook.h"

@interface SFFacebookRequest (Private)

- (void)releaseObjects;

@end

@implementation SFFacebookRequest

+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [[[self alloc] initWithFacebook:facebook graphPath:graphPath needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock] autorelease];
}

+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [[[self alloc] initWithFacebook:facebook graphPath:graphPath params:params needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock] autorelease];
}

+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [[[self alloc] initWithFacebook:facebook graphPath:graphPath params:params httpMethod:httpMethod needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock] autorelease];
}

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [self initWithFacebook:facebook graphPath:graphPath params:[NSMutableDictionary dictionary] httpMethod:@"GET" needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [self initWithFacebook:facebook graphPath:graphPath params:params httpMethod:@"GET" needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    self = [self init];
    if (self) {
        _isFinished = NO;
        _successBlock = [successBlock copy];
        _failureBlock = [failureBlock copy];
        _cancelBlock = [cancelBlock copy];
        
        SFSocialFacebook *socialFacebook = [SFSocialFacebook sharedInstance];
        
        if (![socialFacebook isSessionValid:needsLogin]) {
            if (needsLogin) {
                
                [socialFacebook loginWithSuccess:^{
                    if (!_isFinished) {
                        _request = [[facebook requestWithGraphPath:graphPath andParams:params andHttpMethod:httpMethod andDelegate:self] retain];
                    }
                } failure:^(BOOL cancelled) {
                    if (cancelled && cancelBlock) {
                        cancelBlock();
                    }
                    else if (failureBlock) {
                        failureBlock(SFError(@"Could not login"));
                    }
                }];
                
            } else {
                
                [socialFacebook getAppAccessTokenWithSuccess:^(NSString *accessToken) {
                    if (!_isFinished) {
                        [params setObject:accessToken forKey:@"access_token"];
                        _request = [[facebook requestWithGraphPath:graphPath andParams:params andHttpMethod:httpMethod andDelegate:self] retain];
                    }
                } failure:failureBlock];
            }
        }
        else
        {
            _request = [[facebook requestWithGraphPath:graphPath andParams:params andHttpMethod:httpMethod andDelegate:self] retain];
        }
        [self retain];
    }
    return self;
}

- (void)dealloc
{
    [_request release];
    [_successBlock release];
    [_failureBlock release];
    [_cancelBlock release];
    
    [super dealloc];
}

- (void)cancel
{
    if (!_isFinished) {
        if (_request) {
            [_request cancel];
        } else {
            if (_cancelBlock) {
                _cancelBlock();
            }
            
            [self releaseObjects];
        }
    }
}

#pragma mark - Private

- (void)releaseObjects
{
    [_request release], _request = nil;
    [_successBlock release], _successBlock = nil;
    [_failureBlock release], _failureBlock = nil;
    [_cancelBlock release], _cancelBlock = nil;
    _isFinished = YES;
    [self release];
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
    
	SFDLog(@"Error: %@", [error localizedDescription]);
    
    if (_failureBlock) {
        _failureBlock(error);
    }
    [self releaseObjects];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    
    SFDLog(@"Request loaded with result: %@", result);
    
    if (_successBlock) {
        _successBlock(result);
    }
    [self releaseObjects];
}

- (void)requestDidCancel:(FBRequest *)request
{
    SFDLog(@"Request cancelled");
    
    if (_cancelBlock) {
        _cancelBlock();
    }
    
    [self releaseObjects];
}

@end
