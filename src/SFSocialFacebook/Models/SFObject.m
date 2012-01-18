//
//  SFObject.m
//  SFSocialFacebook
//
//  Created by Massaki on 1/16/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "SFObject.h"

@implementation SFObject

@synthesize objectId;
@synthesize name;


- (NSString *)pictureUrl
{
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [self objectId]];
}

- (NSString *)pictureUrlWithType:(SFObjectPictureType)type
{
    NSString *pictureType = nil;
    switch (type) {
        case SFObjectPictureTypeSquare:
            pictureType = @"square";
            break;
        case SFObjectPictureTypeSmall:
            pictureType = @"small";
            break;
        case SFObjectPictureTypeNormal:
            pictureType = @"normal";
            break;
        case SFObjectPictureTypeLarge:
            pictureType = @"large";
            break;
        default:
            pictureType = @"";
            break;
    }
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@", [self objectId], pictureType];
}

@end
