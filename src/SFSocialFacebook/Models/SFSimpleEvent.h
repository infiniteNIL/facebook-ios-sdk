//
//  SFSimpleEvent.h
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFSimpleEvent : NSObject {
	NSString *eventId;
	NSString *eventName;	
	NSString *eventDescription;
	NSDate *eventStartTime;
	NSDate *eventEndTime;
	NSString *eventLocation;
}


@property(nonatomic, retain) NSString *eventId;
@property(nonatomic, retain) NSString *eventName;	
@property(nonatomic, retain) NSString *eventDescription;
@property(nonatomic, retain) NSDate *eventStartTime;
@property(nonatomic, retain) NSDate *eventEndTime;
@property(nonatomic, retain) NSString *eventLocation;

@end
