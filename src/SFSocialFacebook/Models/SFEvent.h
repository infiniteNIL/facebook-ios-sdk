//
//  SFSimpleEvent.h
//  SFSocialFacebook
//
//  Created by Massaki on 1/16/12.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObject.h"

@class SFSimpleUser;

@interface SFEvent : SFObject

@property(nonatomic, retain) SFSimpleUser *owner;
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