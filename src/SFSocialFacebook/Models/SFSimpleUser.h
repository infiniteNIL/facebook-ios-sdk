//
//  SFSimpleUser.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SFUserPictureTypeSquare,
    SFUserPictureTypeSmall,
    SFUserPictureTypeNormal,
    SFUserPictureTypeLarge,
} SFUserPictureType;

@interface SFSimpleUser : NSObject

@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *name;

- (NSString *)pictureUrl;
- (NSString *)pictureUrlWithType:(SFUserPictureType)type;

@end
