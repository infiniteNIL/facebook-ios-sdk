//
//  SFSocialFacebook.h
//  POCShareComponent
//
//  Created by Bruno Toshio Sugano on 2/16/11.
//  Copyright 2011 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "SFSimplePost.h"
#import "SFUser.h"
#import "SFSimpleEvent.h"
#import "SFSimpleEventInvite.h"
//#import "SFAuthorization.h"

#define SF_FEEDS @"feed"


typedef void (^SFDidNotLoginBlock)(BOOL cancelled);
typedef void (^SFFeedsBlock)(NSArray *posts);
typedef void (^SFFailureBlock)(NSError *error);
typedef void (^SFBasicBlock)(void);


@protocol SFPostDatasource;

@class SFURLRequest;

@interface SFSocialFacebook : NSObject <FBSessionDelegate, FBRequestDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {
    
    Facebook            *_facebook;
	NSString            *_appId;
    NSString            *_appSecret;
    FBRequest           *_fbRequest;
    NSString            *_appAccessToken;
    
    NSURLConnection     *_connection;
    NSMutableData       *_receivedData;
    
    SFURLRequest        *_urlRequest;
    
    NSInteger           _currentAPICall;
    id                  _successBlock;
    SFFailureBlock      _failureBlock;
    SFBasicBlock        _cancelBlock;
    
    SFBasicBlock        _loginBlock;
    SFDidNotLoginBlock  _notLoginBlock;
    SFBasicBlock        _logoutBlock;
    
    
//    SFAuthorization *authSingleton;
	NSString *facebookUserId;
    int areaId;
	NSString *_feedsNextPage;
	
	NSString *nextPageFriends;
	NSString *nextPageInvited;
	
    NSString *shingleServerPath;
	
	SEL pendingAction;
	NSMutableDictionary *pendingActionParams;
	
    BOOL auxFeedsLastPost;
}

+ (SFSocialFacebook *)sharedInstance;

@property (nonatomic, assign) id<SFPostDatasource> delegate;
@property (nonatomic, retain) NSArray *permissions;

@property (nonatomic, retain) NSString *facebookUserId;
@property (nonatomic, retain) NSString *loggedUserId;

- (id)initWithAppId:(NSString *)appId appSecret:(NSString *)appSecret andDelegate:(id<SFPostDatasource>)delegate;
- (id)initWithAppId:(NSString *)appId appSecret:(NSString *)appSecret urlSchemeSuffix:(NSString *)urlSchemeSuffix andDelegate:(id<SFPostDatasource>)delegate;

- (void)loginWithSuccess:(SFBasicBlock)successBlock failure:(SFDidNotLoginBlock)failureBlock;
- (void)logoutWithSuccess:(SFBasicBlock)successsBlock;
- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)isSessionValid;

- (void)listFeedsFromUser:(NSString *)userId 
                 pageSize:(int)postsPerPage 
                  success:(SFFeedsBlock)successBlock 
                  failure:(SFFailureBlock)failureBlock
                   cancel:(SFBasicBlock)cancelBlock;

//- (id) initWithAppId: (NSString *) applicationId
//andAuthorizationSingleton: (SFAuthorization *) authorizationSingleton
//         andDelegate:(id)_delegate;
//
//- (id) initWithAppId: (NSString *) applicationId
//           andAreaId: (int) area_Id
//andAuthorizationSingleton: (SFAuthorization *) authorizationSingleton
//andShingleServerPath: (NSString *) shinglePath
//         andDelegate:(id)_delegate;
//- (void) setAppId: (NSString *) applicationId
//        andAreaId: (int) area_Id
//andAuthorizationSingleton: (SFAuthorization *) authorizationSingleton
//andShingleServerPath: (NSString *) shinglePath
//      andDelegate:(id)_delegate;


- (void) listAreaFeedsWithPostsPerPage: (int)postsPerPage;
- (void) listNextPage;

- (void) handleLike: (NSString *) postId;
//- (void) handleComment: (NSString *) comment InPost: (NSString *) postId;
//- (void) handleUnlike: (NSString *) postId;
- (void) fillUser: (SFUser *)user WithId: (NSString *)userId Target:(id)target AndSelector:(SEL)didFinish;
- (void) fillUser: (SFUser *)user Target:(id)target AndSelector:(SEL)didFinish;
- (void) shareFeed: (SFSimplePost *)post;
- (void) shareFeed: (SFSimplePost *)post WithComment: (NSString *)comment;

- (void) createEvent: (SFSimpleEvent *)event;
- (void) inviteFriendsToEvent: (SFSimpleEventInvite *)invite;
- (void) performPendingAction;
- (void) listFriendsOfLoggedUser: (int) pageSize;
- (void) listNextPageUser;
- (void) getEvent: (NSString*) eventId;
- (void) getInvitedUsersForEvent: (NSString *) eventId PageSize: (int) pageSize;
- (void) listNextPageInvited;
- (void) eventMarkAttending: (NSString *)eventId;
- (void) getNumLikesFromPage: (NSString *)pageId;
- (void) getAccessTokenWithClientId:(NSString*)client_id andClientSecret:(NSString*)client_secret;

- (NSDate*) parseToDate:(NSString *) string;

@end


@protocol SFPostDatasource<NSObject>

@optional

- (void) socialFacebook: (SFSocialFacebook *)facebook ReceivedListOfFriends: (NSArray *)friends;
- (void) socialFacebook: (SFSocialFacebook *)facebook DidSharePost: (NSString *)postId;
- (void) socialFacebook: (SFSocialFacebook *)facebook DidCreateEventWithId: (NSString *)eventId;
- (void) socialFacebookDidSendInvitationToEvent: (SFSocialFacebook *)facebook;
- (void) socialFacebookDidAttendingEvent: (SFSocialFacebook *)facebook;
- (void) socialFacebookDidLike: (SFSocialFacebook *)facebook;
- (void) socialFacebook: (SFSocialFacebook *)facebook DidReceiveEvent: (SFSimpleEvent *)event;
- (void) socialFacebook: (SFSocialFacebook *)facebook DidReceivedInvitedUsersList: (NSArray *)invitedUsers;
- (void) socialFacebook: (SFSocialFacebook *)facebook DidReceiveNumberOfLikes: (NSString *)likes;
- (void) socialFacebookDidLogin;
- (void) socialFacebookDidCancelLogin;
- (void) socialFacebookDidReceiveConfiguration;
- (void) socialFacebookDidFailReceivingConfiguration;
@end
