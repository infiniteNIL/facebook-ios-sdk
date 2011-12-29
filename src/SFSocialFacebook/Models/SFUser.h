//
//  SFUser.h
//  NBC
//
//  Created by Bruno Toshio Sugano on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"


typedef enum {
    SFUserRSVPStatusNotReplied,
    SFUserRSVPStatusAttending,
    SFUserRSVPStatusMaybe,
    SFUserRSVPStatusDeclined,
} SFUserRSVPStatus;

@interface SFUser : NSObject<FBRequestDelegate> {
	NSString *userId;
	NSString *name;
	NSString *imageUrl;
	NSNumber *numLikes;
	id target;
	SEL finishAction;
}

@property(nonatomic, retain)NSString *userId;
@property(nonatomic, retain)NSString *name;
@property(nonatomic, retain)NSString *imageUrl;
@property(nonatomic, retain)NSNumber *numLikes;
@property(nonatomic, assign)SFUserRSVPStatus rsvpStatus;

@property(assign) id target;
@property(assign) SEL finishAction;

@end
