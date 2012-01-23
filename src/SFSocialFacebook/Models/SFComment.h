//
//  SFComment.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSimpleUser;

@interface SFComment : NSObject

@property(nonatomic, retain) NSString *objectId;
@property(nonatomic, retain) SFSimpleUser *from;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSDate *createdTime;
@property(nonatomic) NSUInteger numberOfLikes;
@property(nonatomic) BOOL userLikes;

@end
