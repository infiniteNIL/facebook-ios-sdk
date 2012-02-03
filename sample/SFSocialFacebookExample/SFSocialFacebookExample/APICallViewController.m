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

- (SFSimplePost *)postExample;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
- (void)shingleConfiguration;

- (void)login;
- (void)logout;
- (void)uninstallApp;
- (void)publish;
- (void)publishToFriend;
- (void)createEvent;
- (void)listEvents;
- (void)eventDetails;
- (void)attendEvent;
- (void)inviteFriends;
- (void)listInvitedUsers:(NSNumber *)rsvpStatus;
- (void)listPostComments;
- (void)listUsersWhoLikedPost;
- (void)commentPost;
- (void)likeObject;
- (void)publishToPage;


@end

@implementation APICallViewController

- (id)initWithMenu:(NSString *)menu
{
    [self init];
    if (self) {
        _menuOptions = [[[Menus sharedInstance] performSelector:NSSelectorFromString(menu)] retain];
        self.navigationItem.title = [menu capitalizedString];
    }
    return self;
}

- (id)initWithMenu:(NSString *)menu andObjectId:(NSString *)objectId
{
    [self initWithMenu:menu];
    if (self) {
        _objectId = [objectId copy];
    }
    return self;
}

- (void)dealloc {
    [_urlRequest cancel];
    [_facebookRequest cancel];
    
    [_tableView release];
    [_menuOptions release];
    [_objectId release];
    
    [_urlRequest release];
    [_facebookRequest release];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    if (_urlRequest) {
        [_urlRequest cancel];
        [_urlRequest release], _urlRequest = nil;
    }
    
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release], _facebookRequest = nil;
    }
    
    [super viewWillDisappear:animated];
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

- (SFSimplePost *)postExample
{
    SFSimplePost *post = [[SFSimplePost alloc] init];
    post.name = @"I'm using the I.ndigo Test App for iOS app";
    post.caption = @"I.ndigo Test App for iOS.";
    post.postDescription = @"Check out I.ndigo Test App for iOS to learn how you can make your iOS apps social using Facebook Platform.";
    post.link = @"http://www.i.ndigo.com.br/";
    post.picture = @"https://fbcdn-photos-a.akamaihd.net/photos-ak-snc1/v85006/197/198801296855729/app_1_198801296855729_3543.gif";
    post.actionName = @"I.ndigo Website";
    post.actionLink = @"http://i.ndigo.com.br";
    
    return [post autorelease];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - Shingle Call

- (void)shingleConfiguration
{
    if (_urlRequest) {
        [_urlRequest cancel];
        [_urlRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _urlRequest = [[[SFSocialFacebook sharedInstance] shingleConfigurationWithUrl:@"http://icardinal-develop.heroku.com/" andArea:110 success:^(NSString *profile, BOOL needsLogin) {
        [self showAlertViewWithTitle:@"Shingle Configuration" message:[NSString stringWithFormat:@"profileId: %@\nneedsLogin: %@", profile, (needsLogin? @"YES" : @"NO")]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Shingle configuration request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

#pragma mark - API Calls

- (void)login
{
    [[SFSocialFacebook sharedInstance] loginWithSuccess:^{
        [self showAlertViewWithTitle:@"Login" message:@"Success"];
    } failure:^(BOOL cancelled) {
        [self showAlertViewWithTitle:@"Login Failed" message:(cancelled)? @"Login was cancelled" : nil];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[SFSocialFacebook sharedInstance] uninstallApp:^{
        [self showAlertViewWithTitle:@"Uninstall App" message:@"Success"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:@"Uninstall App" message:@"Canceled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)publish
{
    [[SFSocialFacebook sharedInstance] publishPost:[self postExample] success:^(NSString *postId) {
        [self showAlertViewWithTitle:@"Success" message:[NSString stringWithFormat:@"Comment created with id: %@", postId]];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"User cancelled"];
    }];
}

- (void)publishToFriend
{
    [[SFSocialFacebook sharedInstance] friendsWithPageSize:30 success:^(NSArray *friends, NSString *nextPageUrl) {
        
        if ([friends count] > 0) {
                        
            int randomNumber = arc4random() % [friends count];
            SFSimpleUser *userTo = [[SFSimpleUser alloc] init];
            userTo.objectId = [[friends objectAtIndex:randomNumber] objectId];
            
            SFSimplePost *post = [self postExample];
            post.to = [NSArray arrayWithObject:userTo];
            
            [userTo release];
            
            [[SFSocialFacebook sharedInstance] publishPost:post success:^(NSString *postId) {
                [self showAlertViewWithTitle:nil message:@"Success!"];
            } failure:^(NSError *error) {
                [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
            } cancel:^{
                [self showAlertViewWithTitle:nil message:@"User cancelled"];
            }];
        } else {
            [self showAlertViewWithTitle:nil message:@"You do not have any friends to post to."];
        }
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List friends request was cancelled"];
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
    
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] createEvent:event success:^(NSString *objectId) {
        [self showAlertViewWithTitle:@"Success" message:[NSString stringWithFormat:@"Event id: %@", objectId]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Create event request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
    
    [event release];
}

- (void)listEvents
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] eventsWithPageSize:0 success:^(NSArray *objects, NSString *nextPageUrl) {
        
        __block UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:objects type:ObjectTypeEvent pickerType:ObjectPickerTypeOne completion:^(NSArray *selectedIds) {
            
            UIViewController *eventCtrl = [[APICallViewController alloc] initWithMenu:@"event" andObjectId:[selectedIds objectAtIndex:0]];
            [ctrl.navigationController pushViewController:eventCtrl animated:YES];
            [eventCtrl release];
            
        }];
        
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List events request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)eventDetails
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] eventWithId:_objectId needsLogin:YES success:^(SFEvent *event) {
        [self showAlertViewWithTitle:@"Event" message:[event description]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failureBlock:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Event details request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)attendEvent
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] attendEvent:_objectId success:^{
        [self showAlertViewWithTitle:@"Attend event" message:@"Success"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Attend event request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)inviteFriends
{
    __block SFSocialFacebook *socialFacebook = [SFSocialFacebook sharedInstance];
    
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[socialFacebook friendsWithPageSize:0 success:^(NSArray *friends, NSString *nextPageUrl) {
        
        UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:friends type:ObjectTypeUser pickerType:ObjectPickerTypeMany completion:^(NSArray *selectedIds) {
            
            if ([selectedIds count] > 0) {
            
                _facebookRequest = [[socialFacebook inviteUsers:selectedIds toEvent:_objectId success:^{
                    [self showAlertViewWithTitle:@"Success" message:@"Users invited successfully"];
                } failure:^(NSError *error) {
                    [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
                } cancel:^{
                    [self showAlertViewWithTitle:nil message:@"Invite users request was cancelled"];
                }] retain];
                
            } else {
                [self showAlertViewWithTitle:nil message:@"No users was selected"];
            }
            
            
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
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List friends request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)listInvitedUsers:(NSNumber *)rsvpStatus
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] invitedUsersForEvent:_objectId rsvpStatus:[rsvpStatus intValue] pageSize:0 success:^(NSArray *users, NSString *nextPageUrl) {
        
        UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:users type:ObjectTypeUser pickerType:ObjectPickerTypeNone completion:NULL];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"List invited users request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)listPostComments
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] commentsFromPost:_objectId pageSize:0 needsLogin:NO success:^(NSArray *comments, NSString *nextPageUrl) {
        
        __block UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:comments type:ObjectTypeComment pickerType:ObjectPickerTypeOne completion:^(NSArray *selectedIds) {
            
            UIViewController *commentCtrl = [[APICallViewController alloc] initWithMenu:@"comment" andObjectId:[selectedIds objectAtIndex:0]];
            [ctrl.navigationController pushViewController:commentCtrl animated:YES];
            [commentCtrl release];
            
        }];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Post comments request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)listUsersWhoLikedPost
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] usersWhoLikedPost:_objectId pageSize:0 needsLogin:NO success:^(NSArray *users, NSString *nextPageUrl) {
        
        UIViewController *ctrl = [[ObjectPickerController alloc] initWithObjects:users type:ObjectTypeUser pickerType:ObjectPickerTypeNone completion:NULL];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Post comments request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];
}

- (void)commentPost
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release], _facebookRequest = nil;
    }
    
    [[SFSocialFacebook sharedInstance] commentPost:_objectId success:^(NSString *objectId) {
        [self showAlertViewWithTitle:@"Success" message:[NSString stringWithFormat:@"Comment created with id: %@", objectId]];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"User cancelled"];
    }];
}

- (void)likeObject
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] likeObject:_objectId success:^{
        
        [self showAlertViewWithTitle:@"Success" message:@"You liked this object"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"Post comments request was cancelled"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] retain];

}

- (void)publishToPage
{
    [[SFSocialFacebook sharedInstance] publishPost:[self postExample] onPage:@"indigotest" success:^(NSString *postId) {
        [self showAlertViewWithTitle:@"Success" message:[NSString stringWithFormat:@"Post created with id: %@", postId]];
    } failure:^(NSError *error) {
        [self showAlertViewWithTitle:@"Error" message:[error localizedDescription]];
    } cancel:^{
        [self showAlertViewWithTitle:nil message:@"User cancelled"];
    }];
}

@end
