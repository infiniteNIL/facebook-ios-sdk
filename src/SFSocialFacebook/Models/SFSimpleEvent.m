//
//  SFSimpleEvent.m
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFSimpleEvent.h"


@implementation SFSimpleEvent

@synthesize eventId, eventName, eventDescription, eventStartTime, eventEndTime, eventLocation;

-(void) dealloc {
	[eventId release];
	[eventName release];
	[eventDescription release];
	[eventStartTime release];
	[eventEndTime release];
	[eventLocation release];
	[super dealloc];
}

@end
