//
//  Menus.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/5/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "Menus.h"
#import "SFSimpleUser.h"

@interface Menus (Private)

- (NSArray *)main;
- (NSArray *)login;
- (NSArray *)newsFeed;
- (NSArray *)events;
- (NSArray *)event;
- (NSArray *)post;
- (NSArray *)comment;


@end

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
                                 @"APICallViewController", @"controller",
                                 @"initWithMenu:", @"selector",
                                 @"newsFeed", @"arg",
                                 nil];
    
    NSDictionary *menuOption3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Events", @"title", 
                                 @"APICallViewController", @"controller",
                                 @"initWithMenu:", @"selector",
                                 @"events", @"arg",
                                 nil];
    
    NSDictionary *menuOption4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Shingle Configuration", @"title", 
                                 @"shingleConfiguration", @"method",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2,
                     menuOption3, 
                     menuOption4, 
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    [menuOption3 release];
    [menuOption4 release];
    
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

- (NSArray *)newsFeed
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Publish to your wall", @"title", 
                                 @"publish", @"method",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Publish to friend's wall", @"title", 
                                 @"publishToFriend", @"method",
                                 nil];
    
    NSDictionary *menuOption2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Publish to page's wall", @"title", 
                                 @"publishToPage", @"method",
                                 nil];
    
    NSDictionary *menuOption3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Publish to your wall without Dialog", @"title", 
                                 @"publishWithoutDialog", @"method",
                                 nil];

    NSDictionary *menuOption4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Publish to page's wall without Dialog", @"title", 
                                 @"publishToPageWithoutDialog", @"method",
                                 nil];

    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2, 
                     menuOption3, 
                     menuOption4, 
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    [menuOption3 release];
    [menuOption4 release];
    
    return menu;
}

- (NSArray *)events
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Create an event", @"title", 
                                 @"createEvent", @"method",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"My events", @"title", 
                                 @"listEvents", @"method",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    
    return menu;
}

- (NSArray *)event
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Event details", @"title", 
                                 @"eventDetails", @"method",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Attend event", @"title", 
                                 @"attendEvent", @"method",
                                 nil];
        
    NSDictionary *menuOption2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Invite friends", @"title", 
                                 @"inviteFriends", @"method",
                                 nil];
    
    NSDictionary *menuOption3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Invitee list", @"title", 
                                 @"listInvitedUsers:", @"method",
                                 [NSNumber numberWithInt:SFUserRSVPStatusUnknown], @"arg", 
                                 nil];
    
    NSDictionary *menuOption4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Attending list", @"title", 
                                 @"listInvitedUsers:", @"method",
                                 [NSNumber numberWithInt:SFUserRSVPStatusAttending], @"arg", 
                                 nil];
    
    NSDictionary *menuOption5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Maybe list", @"title", 
                                 @"listInvitedUsers:", @"method",
                                 [NSNumber numberWithInt:SFUserRSVPStatusMaybe], @"arg", 
                                 nil];
    
    NSDictionary *menuOption6 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Declined list", @"title", 
                                 @"listInvitedUsers:", @"method",
                                 [NSNumber numberWithInt:SFUserRSVPStatusDeclined], @"arg", 
                                 nil];
    
    NSDictionary *menuOption7 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Not replied list", @"title", 
                                 @"listInvitedUsers:", @"method",
                                 [NSNumber numberWithInt:SFUserRSVPStatusNotReplied], @"arg", 
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2, 
                     menuOption3, 
                     menuOption4, 
                     menuOption5, 
                     menuOption6, 
                     menuOption7, 
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    [menuOption3 release];
    [menuOption4 release];
    [menuOption5 release];
    [menuOption6 release];
    [menuOption7 release];
    
    return menu;
}

- (NSArray *)post
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Comments", @"title", 
                                 @"listPostComments", @"method",
                                 nil];
    
    NSDictionary *menuOption1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Who likes this", @"title", 
                                 @"listUsersWhoLikedPost", @"method",
                                 nil];
    
    NSDictionary *menuOption2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Comment", @"title", 
                                 @"commentPost", @"method",
                                 nil];
    
    NSDictionary *menuOption3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Like", @"title", 
                                 @"likeObject", @"method",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     menuOption1, 
                     menuOption2, 
                     menuOption3, 
                     nil];
    
    [menuOption0 release];
    [menuOption1 release];
    [menuOption2 release];
    [menuOption3 release];
    
    return menu;
}

- (NSArray *)comment
{
    NSDictionary *menuOption0 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Like", @"title", 
                                 @"likeObject", @"method",
                                 nil];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     menuOption0, 
                     nil];
    
    [menuOption0 release];
    
    return menu;
}


@end
