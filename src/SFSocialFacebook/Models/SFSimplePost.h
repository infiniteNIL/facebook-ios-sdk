//
//  SFSimplePost.h
//  SFSocialFacebook
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSimpleUser;


@interface SFSimplePost : NSObject {
	BOOL _userLikesIt;
}

@property(nonatomic, retain) NSString *postId;
@property(nonatomic, retain) SFSimpleUser *from;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *picture;
@property(nonatomic, retain) NSString *link;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *caption;
@property(nonatomic, retain) NSString *postDescription;
@property(nonatomic, retain) NSString *source;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSNumber *numLikes;
@property(nonatomic, retain) NSNumber *numComments;
@property(nonatomic, retain) NSArray *comments;
@property(nonatomic, retain) NSDate *createdTime;
@property(nonatomic, retain) NSDate *updatedTime;
@property(nonatomic, retain) NSArray *to;
@property(nonatomic, retain) NSString *actionName;
@property(nonatomic, retain) NSString *actionLink;

- (BOOL)userLikesIt;
- (NSString *)getIntervalDescriptionFromCreationDate;

@end




