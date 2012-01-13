//
//  SFSimpleEvent.h
//  NBC
//
//  Created by Bruno Toshio Sugano on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class SFSimpleUser;

@interface SFEvent : NSObject {
    CALayer *a;
}

@property(nonatomic, retain) NSString *eventId;
@property(nonatomic, retain) SFSimpleUser *owner;
@property(nonatomic, retain) NSString *name;	
@property(nonatomic, retain) NSString *eventDescription;
@property(nonatomic, retain) NSDate *startTime;
@property(nonatomic, retain) NSDate *endTime;
@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) NSString *privacy;

@end

/** Event `privacy' values **/
 
extern NSString *const kSFEventPrivacyPublic;
extern NSString *const kSFEventPrivacyClosed;
extern NSString *const kSFEventPrivacySecret;