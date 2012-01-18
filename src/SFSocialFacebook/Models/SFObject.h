//
//  SFObject.h
//  SFSocialFacebook
//
//  Created by Massaki on 1/16/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SFObjectPictureTypeSquare,
    SFObjectPictureTypeSmall,
    SFObjectPictureTypeNormal,
    SFObjectPictureTypeLarge,
} SFObjectPictureType;


@interface SFObject : NSObject

@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *name;

- (NSDictionary *)dictionary;

- (NSString *)pictureUrl;
- (NSString *)pictureUrlWithType:(SFObjectPictureType)type;

@end
