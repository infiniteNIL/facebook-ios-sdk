//
//  SFSimpleUser.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SFSimpleUser.h"

@implementation SFSimpleUser

@synthesize userId;
@synthesize name;

- (NSString *)pictureUrl
{
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [self userId]];
}

- (NSString *)pictureUrlWithType:(SFUserPictureType)type
{
    NSString *pictureType = nil;
    switch (type) {
        case SFUserPictureTypeSquare:
            pictureType = @"square";
            break;
        case SFUserPictureTypeSmall:
            pictureType = @"small";
            break;
        case SFUserPictureTypeNormal:
            pictureType = @"normal";
            break;
        case SFUserPictureTypeLarge:
            pictureType = @"large";
            break;
        default:
            pictureType = @"";
            break;
    }
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@", [self userId], pictureType];
}

- (void)dealloc {
    [userId release];
    [name release];
    
    [super dealloc];
}

@end
