//
//  SFComment.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SFComment.h"

@implementation SFComment

@synthesize objectId, from, message, createdTime, numberOfLikes, userLikes;

- (void)dealloc
{
    [objectId release];
    [from release];
    [message release];
    [createdTime release];
    
    [super dealloc];
}

@end
