//
//  SFSimpleEventInvite.m
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFSimpleEventInvite.h"


@implementation SFSimpleEventInvite

@synthesize userIds, eventId, message;





-(void) dealloc {
	[userIds release];
	[eventId release];
	[message release];
	[super dealloc];
}

@end
