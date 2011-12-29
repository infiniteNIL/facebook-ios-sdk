//
//  SFUser.m
//  NBC
//
//  Created by Bruno Toshio Sugano on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFUser.h"


@implementation SFUser

@synthesize name, imageUrl, target, finishAction, userId, numLikes, rsvpStatus;


#pragma mark -
#pragma mark FBRequestDelegate

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
//- (void)request:(FBRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	
	NSDictionary *user = [result retain];
	
	[self setUserId:[user objectForKey:@"id"]];
	[self setName:[user objectForKey:@"name"]];
	[self setImageUrl:[user objectForKey:@"picture"]];
	
	[user release];
	[target performSelector:finishAction];
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
//- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data;


#pragma mark -
#pragma mark Dealloc


-(void)dealloc {
	[userId release];
	[name release];
	[imageUrl release];
	[super dealloc];
}

@end
