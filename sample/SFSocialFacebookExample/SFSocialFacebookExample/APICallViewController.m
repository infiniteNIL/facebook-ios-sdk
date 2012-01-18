//
//  APICallViewController.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/5/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "APICallViewController.h"
#import "Menus.h"
#import "SFSocialFacebook.h"
#import "ObjectPickerController.h"

@interface APICallViewController (Private)

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
- (void)login;
- (void)logout;
- (void)uninstallApp;
- (void)publish;
- (void)publishToFriend;
- (void)createEvent;
- (void)listEvents;
- (void)eventDetails;
- (void)inviteFriends;
- (void)listInvitedUsers:(NSNumber *)rsvpStatus;

@end

@implementation APICallViewController

- (id)initWithMenu:(NSString *)menu
{
    self = [super init];
    if (self) {
        _menuOptions = [[[Menus sharedInstance] performSelector:NSSelectorFromString(menu)] retain];
        self.navigationItem.title = [menu capitalizedString];
    }
    return self;
}

- (id)initWithEventId:(NSString *)eventId
{
    self = [self initWithMenu:@"event"];
    if (self) {
        _eventId = [eventId copy];
    }
    return self;
}

- (void)dealloc {
    [_tableView release];
    [_menuOptions release];
    [_eventId release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _tableView = [[UITableView alloc] initWithFrame:[self.view bounds] style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload
{
    [_tableView release], _tableView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *option = [_menuOptions objectAtIndex:[indexPath row]];
    NSString *action = [option objectForKey:@"method"];
    if (action) {
        [self performSelector:NSSelectorFromString(action) withObject:[option objectForKey:@"arg"]];
    }
    else if ((action = [option objectForKey:@"controller"])) {
        Class ctlrClass = NSClassFromString(action);
        SEL selector = NSSelectorFromString([option objectForKey:@"selector"]);
        UIViewController *ctrl = (selector)? [[ctlrClass alloc] performSelector:selector withObject:[option objectForKey:@"arg"]] : [[ctlrClass alloc] init];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_menuOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    NSDictionary *option = [_menuOptions objectAtIndex:[indexPath row]];
    cell.textLabel.text = [option objectForKey:@"title"];
    if ([option objectForKey:@"controller"]) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - Private

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - API Calls

- (void)login
{
    [[SFSocialFacebook sharedInstance] loginWithSuccess:^{
        [self showAlertViewWithTitle:@"Login" message:@"Success"];
    } failure:^(BOOL cancelled) {
        [self showAlertViewWithTitle:@"Login Failed" message:(cancelled)? @"Login cancelled" : nil];
    }];
}

- (void)logout
{
    [[SFSocialFacebook sharedInstance] logoutWithSuccess:^{
        [self showAlertViewWithTitle:@"Logout" message:@"Success"];
    }];
}

- (void)uninstallApp
{
    [[SFSocialFacebook sharedInstance] uninstallApp:^{
        [self showAlertViewWithTitle:@"Uninstall App" message:@"Success"];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:@"Uninstall App" message:@"Canceled"];
    }];
}

- (void)publish
{
    SFSimplePost *post = [[SFSimplePost alloc] init];
    post.name = @"I'm using the I.ndigo Test App for iOS app";
    post.caption = @"I.ndigo Test App for iOS.";
    post.postDescription = @"Check out I.ndigo Test App for iOS to learn how you can make your iOS apps social using Facebook Platform.";
    post.link = @"http://www.i.ndigo.com.br/";
    post.picture = @"https://fbcdn-photos-a.akamaihd.net/photos-ak-snc1/v85006/197/198801296855729/app_1_198801296855729_3543.gif";
    post.actionName = @"I.ndigo Website";
    post.actionLink = @"http://i.ndigo.com.br";
    
    [[SFSocialFacebook sharedInstance] publishPost:post success:^(NSString *postId) {
        [self showAlertViewWithTitle:nil message:@"Success!"];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"User cancelled"];
    }];
    [post release];
}

- (void)publishToFriend
{
    [[SFSocialFacebook sharedInstance] friendsWithPageSize:30 success:^(NSArray *friends, NSString *nextPageUrl) {
        
        if ([friends count] > 0) {
                        
            int randomNumber = arc4random() % [friends count];
            SFSimpleUser *usertTo = [[SFSimpleUser alloc] init];
            usertTo.objectId = [[friends objectAtIndex:randomNumber] userId];
            
            SFSimplePost *post = [[SFSimplePost alloc] init];
            post.to = [NSArray arrayWithObject:usertTo];
            post.name = @"I'm using the I.ndigo Test App for iOS app";
            post.caption = @"I.ndigo Test App for iOS.";
            post.postDescription = @"Check out I.ndigo Test App for iOS to learn how you can make your iOS apps social using Facebook Platform.";
            post.link = @"http://www.i.ndigo.com.br/";
            post.picture = @"https://fbcdn-photos-a.akamaihd.net/photos-ak-snc1/v85006/197/198801296855729/app_1_198801296855729_3543.gif";
            post.actionName = @"I.ndigo Website";
            post.actionLink = @"http://i.ndigo.com.br";
            
            [usertTo release];
            
            [[SFSocialFacebook sharedInstance] publishPost:post success:^(NSString *postId) {
                [self showAlertViewWithTitle:nil message:@"Success!"];
            } failure:^(NSError *error) {
                [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
            } cancel:^{
                [self showAlertViewWithTitle:nil message:@"User cancelled"];
            }];
            [post release];
        } else {
            [self showAlertViewWithTitle:nil message:@"You do not have any friends to post to."];
        }
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Request cancelled"];
    }];
}

- (void)createEvent
{
    SFEvent *event = [[SFEvent alloc] init];
    event.name = @"Social Facebook iOS Event Test";
    NSDate *startTime = [[NSDate alloc] initWithTimeIntervalSinceNow:(60*60*24)]; // One day from now
    event.startTime = startTime;
    event.endTime = [startTime dateByAddingTimeInterval:(60*60*4)]; // 4 hours duration
    event.eventDescription = @"Event created by SFSocialFacebook";
    event.location = @"I.ndigo";
    event.privacy = kSFEventPrivacySecret;
    
    [startTime release];
    
    [[SFSocialFacebook sharedInstance] createEvent:event success:^(NSString *objectId) {
        [self showAlertViewWithTitle:@"Success" message:[NSString stringWithFormat:@"Event id: %@", objectId]];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Create event request cancelled"];
    }];
    
    [event release];
}

- (void)listEvents
{
    [[SFSocialFacebook sharedInstance] eventsWithPageSize:0 success:^(NSArray *objects, NSString *nextPageUrl) {
        
        __block UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:objects type:ObjectTypeEvent pickerType:ObjectPickerTypeOne completion:^(NSArray *selectedIds) {
            
            UIViewController *eventCtrl = [[APICallViewController alloc] initWithEventId:[selectedIds objectAtIndex:0]];
            [ctrl.navigationController pushViewController:eventCtrl animated:YES];
            [eventCtrl release];
            
        }];
        
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]]; 
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List events request cancelled"];
    }];
}

- (void)eventDetails
{
    [[SFSocialFacebook sharedInstance] eventWithId:_eventId needsLogin:YES success:^(SFEvent *event) {
        [self showAlertViewWithTitle:@"Event" message:[event description]];
    } failureBlock:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Event details request cancelled"];
    }];
}

- (void)inviteFriends
{
    __block SFSocialFacebook *socialFacebook = [SFSocialFacebook sharedInstance];
    
    [socialFacebook friendsWithPageSize:0 success:^(NSArray *friends, NSString *nextPageUrl) {
        
        UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:friends type:ObjectTypeUser pickerType:ObjectPickerTypeMany completion:^(NSArray *selectedIds) {
            [socialFacebook inviteUsers:selectedIds toEvent:_eventId success:^{
                [self showAlertViewWithTitle:@"Success" message:@"Users invited successfully"];
            } failure:^(NSError *error) {
                [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
            } cancel:^{
                [self showAlertViewWithTitle:nil message:@"Invite users request cancelled"];
            }];
            
            if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                [self dismissModalViewControllerAnimated:YES];
            }
            
        }];
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [ctrl release];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self presentViewController:navCtrl animated:YES completion:NULL];
        } else {
            [self presentModalViewController:navCtrl animated:YES];
        }
        [navCtrl release];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List friends request cancelled"];
    }];
}

- (void)listInvitedUsers:(NSNumber *)rsvpStatus
{
    [[SFSocialFacebook sharedInstance] invitedUsersForEvent:_eventId rsvpStatus:[rsvpStatus intValue] pageSize:0 success:^(NSArray *objects, NSString *nextPageUrl) {
        
        UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:objects type:ObjectTypeUser pickerType:ObjectPickerTypeNone completion:NULL];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List invited users request cancelled"];
    }];
}

@end
