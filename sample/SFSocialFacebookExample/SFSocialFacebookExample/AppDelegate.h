//
//  AppDelegate.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/3/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFSocialFacebook;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate> {
    SFSocialFacebook *_socialFacebook;
}

@property (strong, nonatomic) UIWindow *window;

@end
