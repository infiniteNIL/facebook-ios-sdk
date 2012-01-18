//
//  SFSimpleUser.m
//  SFSocialFacebook
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "SFSimpleUser.h"

@implementation SFSimpleUser

@synthesize rsvpStatus;

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super dictionary]];
    [dic addEntriesFromDictionary:[self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"rsvpStatus", nil]]];
    
    return dic;
}

@end
