//
//  SFSimpleUser.h
//  SFSocialFacebook
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObject.h"

typedef enum {
    SFUserRSVPStatusUnknown,
    SFUserRSVPStatusNotReplied,
    SFUserRSVPStatusAttending,
    SFUserRSVPStatusMaybe,
    SFUserRSVPStatusDeclined,
} SFUserRSVPStatus;

@interface SFSimpleUser : SFObject

@property(nonatomic) SFUserRSVPStatus rsvpStatus;

@end
