//
//  Menus.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Menus.h"

@implementation Menus

static Menus *_instance;

+ (Menus *)sharedInstance
{
	@synchronized(self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }
    return _instance;
}

- (NSArray *)main
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Login", @"title", 
                                 @"APICallViewController", @"controller",
                                 @"initWithMenu:", @"selector",
                                 @"login", @"arg",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Timeline", @"title", 
                                 @"TimelineViewController", @"controller",
                                 nil];
    
    NSDictionary *menuOption2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"News feed", @"title", 
                                 @"", @"controller",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2,
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    
    return menu;
}

- (NSArray *)login
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Login", @"title", 
                                 @"login", @"method",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Logout", @"title", 
                                 @"logout", @"method",
                                 nil];
    
    NSDictionary *menuOption2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Uninstall App", @"title", 
                                 @"uninstallApp", @"method",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2,
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    
    return menu;
}

@end
