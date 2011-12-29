//
//  SFSimpleEventInvite.h
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFSimpleEventInvite : NSObject {
	NSArray *userIds;
	NSString *eventId;
	NSString *message;
}

@property(nonatomic, retain) NSArray *userIds;
@property(nonatomic, retain) NSString *eventId;
@property(nonatomic, retain) NSString *message;

@end
