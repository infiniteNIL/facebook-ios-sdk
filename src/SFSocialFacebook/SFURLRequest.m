//
//  SFURLRequest.m
//  facebook-ios-sdk
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import "SFURLRequest.h"
#import "SFUtil.h"

@interface SFURLRequest (Private)

- (void)releaseObjects;

@end

@implementation SFURLRequest

+ (id)requestWithURL:(NSString *)url success:(void (^)(NSData *))successBlock failure:(void (^)(NSError *))failureBlock
{
    return [[[self alloc] initWithURL:url success:successBlock failure:failureBlock] autorelease];
}

- (id)initWithURL:(NSString *)url success:(void (^)(NSData *))successBlock failure:(void (^)(NSError *))failureBlock
{
    self = [self init];
    if (self) {
        // Create the request.
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        // create the connection with the request
        // and start loading the data
        _connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (_connection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _receivedData = [[NSMutableData data] retain];
            
            _successBlock = [successBlock copy];
            _failureBlock = [failureBlock copy];
        } else {
            
            // Connection failed.
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Could not create connection" forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class]) code:0 userInfo:errorDetail];
            
            failureBlock(error);
            [error release];
        }
    }
    return self;
}


- (void)cancel
{
    [_connection cancel];
    [self releaseObjects];
}

#pragma mark - Dealloc

- (void)dealloc
{
    [_connection release];
    [_receivedData release];
    [_successBlock release];
    [_failureBlock release];
    
    [super dealloc];
}

#pragma mark - Private

- (void)releaseObjects
{
    [_connection release], _connection = nil;
    [_receivedData release], _receivedData = nil;
    [_successBlock release], _successBlock = nil;
    [_failureBlock release], _failureBlock = nil;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _successBlock(_receivedData);
    
    [self releaseObjects];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Connection failed
    _failureBlock(error);
    
    [self releaseObjects];
    
    SFDLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
