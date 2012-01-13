//
//  SFSimpleEvent.m
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFEvent.h"

NSString *const kSFEventPrivacyPublic = @"PUBLIC";
NSString *const kSFEventPrivacyClosed = @"CLOSED";
NSString *const kSFEventPrivacySecret = @"SECRET";

@implementation SFEvent

@synthesize eventId, owner, name, eventDescription, startTime, endTime, location, privacy;

-(void) dealloc {
	[eventId release];
    [owner release];
	[name release];
	[eventDescription release];
	[startTime release];
	[endTime release];
	[location release];
    [privacy release];
    
	[super dealloc];
}

@end
