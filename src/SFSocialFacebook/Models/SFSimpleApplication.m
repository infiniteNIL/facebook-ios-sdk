//
//  SFSimpleApplication.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/31/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "SFSimpleApplication.h"

@implementation SFSimpleApplication

@synthesize iconUrl;

- (void)dealloc
{
    [iconUrl release];
    
    [super dealloc];
}

@end
