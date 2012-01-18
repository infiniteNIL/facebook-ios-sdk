//
//  SFSimpleEvent.m
//  SFSocialFacebook
//
//  Created by Massaki on 1/16/12.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import "SFEvent.h"

NSString *const kSFEventPrivacyPublic = @"PUBLIC";
NSString *const kSFEventPrivacyClosed = @"CLOSED";
NSString *const kSFEventPrivacySecret = @"SECRET";

@implementation SFEvent

@synthesize owner, eventDescription, startTime, endTime, location, privacy;

-(void) dealloc {
    [owner release];
	[eventDescription release];
	[startTime release];
	[endTime release];
	[location release];
    [privacy release];
    
	[super dealloc];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super dictionary]];
    [dic addEntriesFromDictionary:[self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"owner", @"eventDescription", @"startTime", @"endTime", @"location", @"privacy", nil]]];
    
    return dic;
}

@end
