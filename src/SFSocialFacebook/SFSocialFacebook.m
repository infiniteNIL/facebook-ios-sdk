//
//  SFSocialFacebook.m
//  POCShareComponent
//
//  Created by Bruno Toshio Sugano on 2/16/11.
//  Copyright 2011 I.ndigo. All rights reserved.
//

#import "SFSocialFacebook.h"
#import "SFUtil.h"
#import "SBJSON.h"
#import "SFURLRequest.h"
#import "SFFacebookRequest.h"

#define GET_FACEBOOK_WITH_AREA @"facebook/getFacebook?area_id="


/*
 
 The last thing that needs to be accomplished to enable SSO support is a change to the .plist 
 file that handles configuration for the app. XCode creates this file automatically when the 
 project is created. A specific URL needs to be registered in this file that uniquely identifies 
 the app with iOS. Create a new row named URL types with a single item, URL Schemes, containing 
 a single value, fbYOUR_APP_ID (the literal characters fb followed by your app id). 
 
 */

typedef enum {
    SFAPICallUninstallApp,
    SFAPICallAppLogin,
    SFAPICallListFeeds,
} SFAPICall;

static NSString* kSFFBRequestAttributeAPICall = @"apiCall";
static NSString* kSFFBRequestAttributeSuccess = @"success";
static NSString* kSFFBRequestAttributeFailure = @"failure";
static NSString* kSFFBRequestAttributeCancel = @"cancel";


@interface SFSocialFacebook (Private)

- (id)initWithAppId:(NSString *)appId appSecret:(NSString *)appSecret urlSchemeSuffix:(NSString *)urlSchemeSuffix andPermissions:(NSArray *)permissions;

- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;

- (SFFacebookRequest *)listProfileFeedWithGraphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(SFFeedsBlock)successBlock failure:(SFFailureBlock)failureBlock cancel:(SFBasicBlock)cancelBlock;

- (void)clearUserInfo;

@end


@implementation SFSocialFacebook

@synthesize delegate = _delegate;


@synthesize facebookUserId;
@synthesize loggedUserId;

#pragma mark - Singleton implementation

// According http://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32

static SFSocialFacebook *_instance;

+ (SFSocialFacebook *)sharedInstance
{
    if (_instance == nil) {
        @throw [NSException exceptionWithName:@"SFSocialFacebook Exception" reason:@"There is no singleton instance" userInfo:nil];
    }
    
    return _instance;
}

+ (SFSocialFacebook *)sharedInstanceWithAppId:(NSString *)appId appSecret:(NSString *)appSecret urlSchemeSuffix:(NSString *)urlSchemeSuffix andPermissions:(NSArray *)permissions
{
	@synchronized(self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:NULL] initWithAppId:appId appSecret:appSecret urlSchemeSuffix:urlSchemeSuffix andPermissions:permissions];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    // do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark - Private Constructor

- (id)initWithAppId:(NSString *)appId appSecret:(NSString *)appSecret urlSchemeSuffix:(NSString *)urlSchemeSuffix andPermissions:(NSArray *)permissions
{
    self = [super init];
    if (self) {
        _permissions = [permissions retain];
        
#ifdef DEBUG
        
        // Check App ID:
        // This is really a warning for the developer, this should not
        // happen in a completed app
        if (!appId) {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:@"Facebook Setup Error" 
                                      message:@"Missing app ID. You cannot run the app until you provide this in the code." 
                                      delegate:self 
                                      cancelButtonTitle:@"OK" 
                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        } else {
            // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
            // be opened, doing a simple check without local app id factored in here
            NSString *url = [NSString stringWithFormat:@"fb%@://authorize",appId];
            BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
            NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
            if ([aBundleURLTypes isKindOfClass:[NSArray class]] && 
                ([aBundleURLTypes count] > 0)) {
                
                for (NSDictionary *aBundleURLType in aBundleURLTypes) {
                    
                    if ([aBundleURLType isKindOfClass:[NSDictionary class]]) {
                        
                        NSArray* aBundleURLSchemes = [aBundleURLType objectForKey:@"CFBundleURLSchemes"];
                        if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                            ([aBundleURLSchemes count] > 0)) {
                            
                            for (NSString *scheme in aBundleURLSchemes) {
                                
                                if ([scheme isKindOfClass:[NSString class]] && 
                                    [url hasPrefix:scheme]) {
                                    bSchemeInPlist = YES;
                                    break;
                                }
                            }
                            
                            if (bSchemeInPlist) {
                                break;
                            }
                        }
                    }
                }
            }
            // Check if the authorization callback will work
            BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
            if (!bSchemeInPlist || !bCanOpenUrl) {
                UIAlertView *alertView = [[UIAlertView alloc] 
                                          initWithTitle:@"Facebook Setup Error" 
                                          message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist." 
                                          delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            } else {
#endif
                // Everything is OK
                _facebook = [[Facebook alloc] initWithAppId:appId urlSchemeSuffix:urlSchemeSuffix andDelegate:self];
                
                // Retrieve authorization information
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults objectForKey:@"FBAccessTokenKey"] 
                    && [defaults objectForKey:@"FBExpirationDateKey"]) {
                    _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
                    _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
                }
                
                _appId = [appId copy];
                _appSecret = [appSecret copy];
#ifdef DEBUG
            }
        }
#endif
    }
    return self;
}

#pragma mark - Methods

- (BOOL)handleOpenURL:(NSURL *)url
{
	return [_facebook handleOpenURL:url];
}

- (BOOL)isSessionValid:(BOOL)needsLogin
{
    BOOL isValid = NO;
    if (needsLogin) {
        isValid = [_facebook isSessionValid];
    } else {
        isValid = [_facebook isSessionValid] || _appAccessToken;
    }
    
    return isValid;
}


- (void)getAppAccessTokenWithSuccess:(void (^)(NSString *))successBlock failure:(SFFailureBlock)failureBlock
{   
    [SFURLRequest requestWithURL:[NSString stringWithFormat:@"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials", _appId, _appSecret] 
                         success:^(NSData *receivedData) {
                             NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                             NSArray *components = [response componentsSeparatedByString:@"="];
                             [response release];
                             
                             if ([components count] == 2) {
                                 // Success
                                 [_appAccessToken release];
                                 _appAccessToken = [[components objectAtIndex:1] retain];
                                 if (successBlock) {
                                     successBlock(_appAccessToken);
                                 }
                             } else {
                                 // Error
                                 if (failureBlock) {
                                     failureBlock(SFError(@"Could not parse App Login Acess Token"));
                                 }
                             }
                         } 
                         failure:failureBlock];
}

- (void)loginWithSuccess:(SFBasicBlock)successBlock failure:(SFDidNotLoginBlock)failureBlock
{
    _loginBlock = [successBlock copy];
    _notLoginBlock = [failureBlock copy];
    
	[_facebook authorize:_permissions];
}

- (void)logoutWithSuccess:(SFBasicBlock)successsBlock
{
    _logoutBlock = [successsBlock copy];
    
	[_facebook logout];
}

- (SFFacebookRequest *)uninstallApp:(SFBasicBlock)successBlock failure:(SFFailureBlock)failureBlock cancel:(SFBasicBlock)cancelBlock
{
    SFFacebookRequest *request = nil;
    
    if ([_facebook isSessionValid]) {
        // Passing empty (no) parameters unauthorizes the entire app. To revoke individual permissions
        // add a permission parameter with the name of the permission to revoke.
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
        
        request = [self facebookRequestWithGraphPath:@"me/permissions" params:params httpMethod:@"DELETE" needsLogin:YES success:^(id result) {
            [self logoutWithSuccess:nil];
            if (successBlock) {
                ((SFBasicBlock)successBlock)();
            }
        } failure:failureBlock cancel:cancelBlock];
        
        [params release];
    }
    else if (failureBlock) {
        failureBlock(SFError(@"User is not logged in"));
    }
    
    return request;
}

- (SFFacebookRequest *)listProfileFeed:(NSString *)profileId pageSize:(int)postsPerPage needsLogin:(BOOL)needsLogin success:(SFFeedsBlock)successBlock failure:(SFFailureBlock)failureBlock cancel:(SFBasicBlock)cancelBlock
{
    return [self listProfileFeedWithGraphPath:[NSString stringWithFormat:@"%@/feed?date_format=U&limit=%d", profileId, postsPerPage] needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (SFFacebookRequest *)listProfileFeedNextPage:(NSString *)nextPageURL success:(SFFeedsBlock)successBlock failure:(SFFailureBlock)failureBlock cancel:(SFBasicBlock)cancelBlock
{
    return [self listProfileFeedWithGraphPath:nextPageURL needsLogin:NO success:successBlock failure:failureBlock cancel:cancelBlock];
}

#pragma mark - Private

- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [self facebookRequestWithGraphPath:graphPath params:[NSMutableDictionary dictionary] httpMethod:@"GET" needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    return [self facebookRequestWithGraphPath:graphPath params:params httpMethod:@"GET" needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (SFFacebookRequest *)facebookRequestWithGraphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock cancel:(void (^)())cancelBlock
{
    if (!needsLogin && _appAccessToken) {
        [params setObject:_appAccessToken forKey:@"access_token"];
    }
    
    return [SFFacebookRequest requestWithFacebook:_facebook graphPath:graphPath params:params httpMethod:httpMethod needsLogin:needsLogin success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (void)clearUserInfo
{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (SFFacebookRequest *)listProfileFeedWithGraphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(SFFeedsBlock)successBlock failure:(SFFailureBlock)failureBlock cancel:(SFBasicBlock)cancelBlock
{
    SFFacebookRequest *request = [self facebookRequestWithGraphPath:[graphPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] needsLogin:needsLogin success:^(id result) {
        SFSimplePost *post = nil;
        NSMutableArray *posts = [NSMutableArray array];
        
        for (id ob in [result objectForKey:@"data"]) {
            post = [[SFSimplePost alloc] init];
            [post setPostId:(NSString *)[ob objectForKey:@"id"]];
            
            if ([[post postId] isEqualToString:@"187347617967964_188827637819962"]) {
                if (auxFeedsLastPost) {
                    [post release];
                    break;
                }
                else {
                    auxFeedsLastPost = YES;
                }				
            }
            
            [post setUserId:[[ob objectForKey:@"from"] objectForKey:@"id"]];
            [post setUserName:(NSString *)[[ob objectForKey:@"from"] objectForKey:@"name"]];
            [post setUserImageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [post userId]]];
            [post setMessage:(NSString *)[ob objectForKey:@"message"]];
            [post setPicture:[ob objectForKey:@"picture"]];
            [post setLink:[ob objectForKey:@"link"]];
            [post setName:[ob objectForKey:@"name"]];
            [post setCaption:[ob objectForKey:@"caption"]];
            [post setSDescription:[ob objectForKey:@"description"]];
            [post setSource:[ob objectForKey:@"source"]];
            [post setType:[ob objectForKey:@"type"]];
            
            [post setCreatedTime:[NSDate dateWithTimeIntervalSince1970:[[ob objectForKey:@"created_time"] doubleValue]]];
            [post setUpdatedTime:[NSDate dateWithTimeIntervalSince1970:[[ob objectForKey:@"updated_time"] doubleValue]]];
            //TODO: Comment
            /*
             if ([ob objectForKey:@"comments"] != nil) {
             [post setNumComments:[NSNumber numberWithInt:[[ob objectForKey:@"comments"] objectForKey:@"count"]]];
             
             
             }
             */
            
            [posts addObject:post];
            [post release];
        }
        
        NSString *nextPage = nil;
        NSDictionary *paging = [result objectForKey:@"paging"];
        if (paging) {
            nextPage = (NSString *)[paging objectForKey:@"next"];
            int pos = [nextPage rangeOfString:@".com/"].location + 5;
            nextPage = [nextPage substringFromIndex:pos];
        }
        if (successBlock) {
            ((SFFeedsBlock)successBlock)(posts, nextPage);
        }
    } failure:failureBlock cancel:cancelBlock];
    
    return request;
}

//- (id)initWithAppId:(NSString *)applicationId andAuthorizationSingleton:(SFAuthorization *)authorizationSingleton andDelegate:(id)_delegate
//{
//    self = [super init];
//    if (self) {
//        _delegate = _delegate;
//        _appId = [applicationId retain];
//        authSingleton = [authorizationSingleton retain];
//        _facebook = [[Facebook alloc] initWithAppId:_appId andAuthorizationSingleton:authSingleton];
//    }
//    return self;
//}
//
//- (id) initWithAppId: (NSString *) applicationId
//           andAreaId: (int) area_Id
//andAuthorizationSingleton: (SFAuthorization *) authorizationSingleton
//andShingleServerPath: (NSString *) shinglePath
//         andDelegate:(id)_delegate{
//    
//	if ((self = [super init])) {
//        [self setAppId:applicationId 
//             andAreaId:areaId 
//andAuthorizationSingleton:authSingleton 
//  andShingleServerPath:shinglePath 
//           andDelegate:_delegate];
//        return self;
//	}
//    
//	return nil;
//}
//
//- (void) setAppId: (NSString *) applicationId
//        andAreaId: (int) area_Id
//andAuthorizationSingleton: (SFAuthorization *) authorizationSingleton
//andShingleServerPath: (NSString *) shinglePath
//      andDelegate:(id)_delegate{
//	
//    _delegate = _delegate;
//    _appId = [applicationId retain];
//    areaId = area_Id;
//    authSingleton = [authorizationSingleton retain];
//    shingleServerPath = [shinglePath retain];
//    
//    facebookUserId = @"";
//    
//    _facebook = [[Facebook alloc] initWithAppId:_appId andAuthorizationSingleton:authSingleton];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@%i",shingleServerPath, GET_FACEBOOK_WITH_AREA, areaId]];
//    
//    receivedData = [[NSMutableData data] retain];
//    
//    conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30] delegate:self startImmediately:TRUE];
//    
//}

//#pragma mark - NSURLConnectionDataDelegate
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    // Discard all previously received data.
//    [_receivedData setLength:0];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    // Append the new data to the receivedData.
//    [_receivedData appendData:data];     
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    if (_successBlock || _failureBlock) {
//    
////        NSString *json =  [[[NSString alloc] initWithData:receivedData encoding:NSStringEnumerationByComposedCharacterSequences] autorelease];
////        NSArray *areaInfo = [json JSONValue];
////        
////        if (areaInfo != nil && [areaInfo count] != 0) {
////            facebookUserId = [[[(NSDictionary *)[areaInfo objectAtIndex:0] objectForKey:@"account_number"] description] retain];
////            NSLog(@"facebookUserId = %@", facebookUserId);
////            
////            NSString* access_token = [(NSDictionary *)[areaInfo objectAtIndex:0] objectForKey:@"access_token"];
////            if([access_token length] > 0){
////                authSingleton.token = access_token;
////                authSingleton.logged = YES;
////                _facebook.accessToken = access_token;
////                NSLog(@"auth_token = %@", authSingleton.token);
////            }
////            
////            
////            if(_delegate && [_delegate respondsToSelector:@selector(socialFacebookDidReceiveConfiguration)]){
////                [_delegate socialFacebookDidReceiveConfiguration];
////            }
////        }
////        else {
////            if(_delegate && [_delegate respondsToSelector:@selector(socialFacebookDidFailReceivingConfiguration)]){
////                [_delegate socialFacebookDidFailReceivingConfiguration];
////            }
////        }
//        
//        
//        switch (_currentAPICall) {
//            case SFAPICallAppLogin: {
//                NSString *response = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
//                NSArray *components = [response componentsSeparatedByString:@"="];
//                [response release];
//                
//                NSString *accessToken = nil;
//                
//                if ([components count] == 2) {
//                    // Success
//                    accessToken = [components objectAtIndex:1];
//                    if (_successBlock) {
//                        ((SFAppLoginBlock)_successBlock)(accessToken);
//                    }
//                } else {
//                    // Error
//                    if (_failureBlock) {
//                        _failureBlock([self errorWithDescription:@"Could not parse App Login Acess Token"]);
//                    }
//                }
//                
//                break;
//            }
//            default:
//                break;
//        }
//    }
//
//    // release the connection, and the data object
//    [self releaseRequestObjects];
//}
//
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
////    if(_delegate && [_delegate respondsToSelector:@selector(socialFacebookDidFailReceivingConfiguration)]){
////        [_delegate socialFacebookDidFailReceivingConfiguration];
////    }
//    
//    [_connection release];
//    [_receivedData release];
//}
//
//#pragma mark -


//- (void) listAreaFeedsWithPostsPerPage:(int)postsPerPage {
//    [self listFeedsFromUser:facebookUserId PageSize:postsPerPage];
//}


- (void) handleLike: (NSString *) postId {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[postId retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(handleLike:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:postId forKey:@"postId"];
		[postId release];
		
		[self login];
	}
	else {
		[postId retain];
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes?identifier=pagelike", postId] andParams:[NSMutableDictionary dictionaryWithObject:_appId forKey:@"app_id"] andHttpMethod:@"POST" andDelegate:self];
		[postId release];
	}	
}


- (void) handleUnlike: (NSString *) postId {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[postId retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(handleUnlike:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:postId forKey:@"postId"];
		[postId release];
		
		[self login];
	}
	else {
		[postId retain];
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/likes?identifier=pageunlike", postId] andParams:[NSMutableDictionary dictionaryWithObject:_appId forKey:@"app_id"] andHttpMethod:@"DELETE" andDelegate:self];
		[postId release];
	}	
}

/*
 - (void) handleComment: (NSString *) comment InPost: (NSString *) postId {
 [delegate retain];
 if (![face isSessionValid]) {
 [comment retain];
 [postId retain];
 if (pendingActionParams != nil) {
 [pendingActionParams release];
 pendingActionParams = nil;
 }
 pendingAction = @selector(handleComment:InPost:);
 
 pendingActionParams = [[NSMutableDictionary alloc] init];
 [pendingActionParams setObject:comment forKey:@"comment"];
 [pendingActionParams setObject:postId forKey:@"postId"];
 [comment release];
 [postId release];
 
 [self handleLogin];
 }
 else {
 [comment retain];
 [postId retain];
 [face requestWithGraphPath:[NSString stringWithFormat:@"%@/comments", postId] andParams:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appId, comment, nil] forKeys:[NSArray arrayWithObjects:@"app_id", @"message", nil]] andHttpMethod:@"POST" andDelegate:self];
 [comment release];
 [postId release];
 }
 }
 */

- (NSDate*) parseToDate:(NSString *) string
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    NSString *format = ([string hasSuffix:@"Z"]) ? @"yyyy-MM-dd'T'HH:mm:ss'Z'" : @"yyyy-MM-dd'T'HH:mm:ssz";
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return [formatter dateFromString:string];
}


- (void) fillUser: (SFUser *)user WithId: (NSString *)userId Target:(id)target AndSelector:(SEL)didFinish {
	[user setTarget:target];
	[user setFinishAction:didFinish];
	[_facebook requestWithGraphPath:userId andParams:nil andDelegate:user];
}

- (void) fillUser: (SFUser *)user Target:(id)target AndSelector:(SEL)didFinish {
    [self fillUser:user WithId:facebookUserId Target:target AndSelector:didFinish];
}


// This method is just to allow the user to "Attend" the main event from where all posts are being shown

- (void) eventMarkAttending: (NSString *)eventId {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[eventId retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(eventMarkAttending:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:eventId forKey:@"eventId"];
		[eventId release];
		
		[self login];
	}
	else {
		[eventId retain];
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		[pars setObject:_appId forKey:@"app_id"];
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/attending", eventId] andParams:pars andHttpMethod:@"POST" andDelegate:self];
		[eventId release];
		[pars release];
	}
}

- (void) shareFeed: (SFSimplePost *)post {
	[self shareFeed:post WithComment:@""];
}

- (void) shareFeed: (SFSimplePost *)post WithComment: (NSString *)comment {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[post retain];
		[comment retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(shareFeed:WithComment:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:post forKey:@"post"];
		[pendingActionParams setObject:comment forKey:@"comment"];
		[post release];
		[comment release];
		
		[self login];
	}
	else {
		[post retain];
		[comment retain];
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		if ([post message] != nil && ![[post message] isEqualToString:@""]) {
			[params setObject:[post message] forKey:@"message"];
		} else if (![comment isEqualToString:@""]) {
			[params setObject:comment forKey:@"message"];
		} else {
			[params setObject:[post sDescription] forKey:@"message"];
		}
        
		
		if ([post picture] != nil && [[post picture] rangeOfString:@"fbcdn"].length <= 0.0) {
			[params setObject:[post picture] forKey:@"picture"];
		}
		if ([post link] != nil) {
			[params setObject:[post link] forKey:@"link"];
		}
		
		if ([post name] != nil) {
			[params setObject:[post name] forKey:@"name"];
		}
		
		if ([post caption] != nil) {
			[params setObject:[post caption] forKey:@"caption"];
		}
		
		if ([post sDescription] != nil) {
			[params setObject:[post sDescription] forKey:@"description"];
		}
		
		if ([post source] != nil) {
			[params setObject:[post source] forKey:@"source"];
		}
		[params setObject:_appId forKey:@"app_id"];
		
		[_facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
		[post release];
		[comment release];
		[params release];
	}
}

- (void) createEvent: (SFSimpleEvent *)event {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[event retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(createEvent:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:event forKey:@"event"];
		[event release];
		
		[self login];
	}
	else {
		[event retain];
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		
		if ([event eventName] != nil) {
			[pars setObject:[event eventName] forKey:@"name"];
		}
		if ([event eventDescription] != nil) {
			[pars setObject:[event eventDescription] forKey:@"description"];
		}
		if ([event eventStartTime] != nil) {
			[pars setObject:[NSString stringWithFormat:@"%f" ,round([[event eventStartTime] timeIntervalSince1970])] forKey:@"start_time"];
		}
		if ([event eventEndTime] != nil) {
			[pars setObject:[NSString stringWithFormat:@"%f" ,round([[event eventEndTime] timeIntervalSince1970])] forKey:@"end_time"];
		}
		if ([event eventLocation] != nil) {
			[pars setObject:[event eventLocation] forKey:@"location"];
		}
		[pars setObject:@"SECRET" forKey:@"privacy_type"];
		[pars setObject:_appId forKey:@"app_id"];
		
		//NSLog(@"Parameters: %@", pars);
		
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"me/events", loggedUserId] andParams:pars andHttpMethod:@"POST" andDelegate:self];
		[event release];
		[pars release];
	}
}


- (void) inviteFriendsToEvent: (SFSimpleEventInvite *)invite {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[invite retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(inviteFriendsToEvent:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:invite forKey:@"invite"];
		[invite release];
		
		[self login];
	}
	else {
		[invite retain];
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		
		if ([invite	eventId] != nil) {
			[pars setObject:[invite eventId] forKey:@"eid"];
		}
		if ([invite userIds] != nil) {
			[pars setObject:[[invite userIds] componentsJoinedByString:@", "] forKey:@"uids"];
		}
		if ([invite message] != nil) {
			[pars setObject:[invite message] forKey:@"personal_message"];
		}
		
		[pars setObject:_appId forKey:@"app_id"];
		
		//NSLog(@"Invites: %@", pars);
		
		[_facebook requestWithMethodName:@"events.invite" andParams:pars andHttpMethod:@"POST" andDelegate:self];
		[invite release];
		[pars release];
	}
}

-(void) listFriendsOfLoggedUser: (int) pageSize {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(listFriendsOfLoggedUser:);
		pendingActionParams = [[NSMutableDictionary	alloc] init];
		[pendingActionParams setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
		
		[self login];
	}
	else {
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		
		[pars setObject:_appId forKey:@"app_id"];
		
		[_facebook requestWithGraphPath:@"me/friends" andParams:pars andDelegate:self];
		[pars release];
	}
}

- (void) listNextPageUser {
	[_delegate retain];
    if (nextPageInvited) {
        [_facebook requestWithGraphPath:nextPageFriends andDelegate:self];
    } else {
        if ([_delegate respondsToSelector:@selector(socialFacebook:ReceivedListOfFriends:)]) {
			[_delegate socialFacebook:self ReceivedListOfFriends:[NSArray array]];
		}
    }
}

- (void) getEvent: (NSString*) eventId {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		
		[eventId retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(getEvent:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:eventId forKey:@"eventId"];
		[eventId release];
		
		[self login];
	}
	else {
		
		[eventId retain];
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		
		[pars setObject:_appId forKey:@"app_id"];
		
		
		
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@?identifier=event", eventId] andParams:pars andHttpMethod:@"GET" andDelegate:self];
		[eventId release];
		[pars release];
	}
}

- (void) getInvitedUsersForEvent: (NSString *) eventId PageSize: (int) pageSize {
	[_delegate retain];
	if (![_facebook isSessionValid]) {
		[eventId retain];
		if (pendingActionParams != nil) {
			[pendingActionParams release];
			pendingActionParams = nil;
		}
		pendingAction = @selector(getInvitedUsersForEvent:PageSize:);
		
		pendingActionParams = [[NSMutableDictionary alloc] init];
		[pendingActionParams setObject:eventId forKey:@"eventId"];
		[pendingActionParams setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
		[eventId release];
		
		[self login];
	}
	else {
		[eventId retain];
		NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
		
		[pars setObject:_appId forKey:@"app_id"];
		
		[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/invited", eventId] andParams:pars andHttpMethod:@"GET" andDelegate:self];
		[eventId release];
		[pars release];
	}
}

- (void) listNextPageInvited {
	[_delegate retain];
    if (nextPageInvited) {
        [_facebook requestWithGraphPath:nextPageInvited andDelegate:self];
    } else {
        if ([_delegate respondsToSelector:@selector(socialFacebook:DidReceivedInvitedUsersList:)]) {
			[_delegate socialFacebook:self DidReceivedInvitedUsersList:[NSArray array]];
		}
    }
}

- (void) getNumLikesFromPage: (NSString *)pageId {
	NSLog(@"pageId: %@", pageId);
	[_delegate retain];
	
	NSMutableDictionary *pars = [[NSMutableDictionary alloc] init];
	
	[pars setObject:_appId forKey:@"app_id"];
	
	[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@?identifier=likes", pageId] andParams:pars andHttpMethod:@"GET" andDelegate:self];
	[pars release];
	
}

-(NSDate *) dateFromString:(NSString *)_date {
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	NSString *format = @"yyyy-MM-dd'T'HH:mm:ss";
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	return [formatter dateFromString:_date];
	
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	
//	NSString *url = [request url];
   
//	else if([url rangeOfString:@"feed"].length > 0.0 && [[request httpMethod] isEqualToString:@"POST"]) {
//		
//		//NSLog(@"share: %@", result);
//		if ([_delegate respondsToSelector:@selector(socialFacebook:DidSharePost:)]) {
//			[_delegate socialFacebook:self DidSharePost:[result objectForKey:@"id"]];
//		}
//	}
//	else if ([url rangeOfString:@"events.invite"].length > 0.0 && [[request httpMethod] isEqualToString:@"POST"]) {
//		
//		if ([_delegate respondsToSelector:@selector(socialFacebookDidSendInvitationToEvent:)]) {
//			[_delegate socialFacebookDidSendInvitationToEvent:self];
//		}
//	}
//	else if ([url rangeOfString:@"events"].length > 0.0 && [[request httpMethod] isEqualToString:@"POST"]) {
//		//NSLog(@"event: %@", result);
//		
//		if ([_delegate respondsToSelector:@selector(socialFacebook:DidCreateEventWithId:)]) {
//			[_delegate socialFacebook:self DidCreateEventWithId:[result objectForKey:@"id"]];
//		}
//	}
//	else if ([url rangeOfString:@"me?fields"].length > 0.0) {
//		loggedUserId = [[result objectForKey:@"id"] retain];
//		[self performPendingAction];
//	}
//	else if ([url rangeOfString:@"me/friends"].length > 0.0) {
//		SFUser *us;
//		NSMutableArray *listUsers = [[[NSMutableArray alloc] init] autorelease];
//		
//		for (id ob in [result objectForKey:@"data"]) {
//			us = [[SFUser alloc] init];
//			[us setName:[ob objectForKey:@"name"]];
//			[us setUserId:[ob objectForKey:@"id"]];
//			[us setImageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [us userId]]];
//			
//			[listUsers addObject:us];
//			[us release];
//		}
//		
//        [nextPageFriends release], nextPageFriends = nil;
//        if ([result objectForKey:@"paging"] != nil) {
//			nextPageFriends = (NSString *)[[result objectForKey:@"paging"] objectForKey:@"next"];
//			int pos = [nextPageFriends rangeOfString:@".com/"].location + 5;
//			nextPageFriends = [[nextPageFriends substringFromIndex:pos] retain];
//		}
//		
//		if ([_delegate respondsToSelector:@selector(socialFacebook:ReceivedListOfFriends:)]) {
//			[_delegate socialFacebook:self ReceivedListOfFriends:listUsers];
//		}
//	}
//	else if ([url rangeOfString:@"/attending"].length > 0.0) {
//		//NSLog(@"result: %@", result);
//		if ([_delegate respondsToSelector:@selector(socialFacebookDidAttendingEvent:)]) {
//			[_delegate socialFacebookDidAttendingEvent:self];
//		}
//	}
//	else if ([url rangeOfString:@"identifier=event"].length > 0.0) {
//		//NSLog(@"result: %@", result);
//		
//		SFSimpleEvent *ev = [[[SFSimpleEvent alloc] init] autorelease];
//		
//		[ev setEventId:[result objectForKey:@"id"]];
//		[ev setEventName:[result objectForKey:@"name"]];
//		[ev setEventStartTime:[self parseToDate:[result objectForKey:@"start_time"]]];
//		[ev setEventEndTime:[self parseToDate:[result objectForKey:@"end_time"]]];
//		
//		if ([result objectForKey:@"description"] != nil) {
//			[ev setEventDescription:[result objectForKey:@"description"]];
//		}
//		
//		if ([result objectForKey:@"location"] != nil) {
//			[ev setEventLocation:[result objectForKey:@"location"]];
//		}		
//		
//		if ([result objectForKey:@"start_time"] != nil) {
//			[ev setEventStartTime:[self dateFromString:(NSString *)[result objectForKey:@"start_time"]]];
//		}		
//		
//		if ([result objectForKey:@"end_time"] != nil) {
//			[ev setEventEndTime:[self dateFromString:(NSString *)[result objectForKey:@"end_time"]]];
//		}		
//        
//		if ([_delegate respondsToSelector:@selector(socialFacebook:DidReceiveEvent:)]) {
//			[_delegate socialFacebook:self DidReceiveEvent:ev];
//		}
//	}
//	else if ([url rangeOfString:@"/invited"].length > 0.0) {
//		SFUser *us;
//		NSMutableArray *listUsers = [[[NSMutableArray alloc] init] autorelease];
//		
//		for (id ob in [result objectForKey:@"data"]) {
//			us = [[SFUser alloc] init];
//			[us setName:[ob objectForKey:@"name"]];
//			[us setUserId:[ob objectForKey:@"id"]];
//			[us setImageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [us userId]]];
//            
//            NSString *rsvpStatus = [ob objectForKey:@"rsvp_status"];
//            
//            if (rsvpStatus != nil) {
//                if ([rsvpStatus isEqualToString:@"not_replied"]) {
//                    [us setRsvpStatus:SFUserRSVPStatusNotReplied];
//                }
//                else if ([rsvpStatus isEqualToString:@"attending"]) {
//                    [us setRsvpStatus:SFUserRSVPStatusAttending];
//                }
//                else if ([rsvpStatus isEqualToString:@"declined"]) {
//                    [us setRsvpStatus:SFUserRSVPStatusDeclined];
//                }
//                else if ([rsvpStatus isEqualToString:@"unsure"]) {
//                    [us setRsvpStatus:SFUserRSVPStatusMaybe];
//                }
//            }
//			
//			[listUsers addObject:us];
//			[us release];
//		}
//		
//        [nextPageInvited release], nextPageInvited = nil;
//		if ([result objectForKey:@"paging"] != nil) {
//			nextPageInvited = (NSString *)[[result objectForKey:@"paging"] objectForKey:@"next"];
//			int pos = [nextPageInvited rangeOfString:@".com/"].location + 5;
//			nextPageInvited = [[nextPageInvited substringFromIndex:pos] retain];
//		}
//		
//		if ([_delegate respondsToSelector:@selector(socialFacebook:DidReceivedInvitedUsersList:)]) {
//			[_delegate socialFacebook:self DidReceivedInvitedUsersList:listUsers];
//		}
//	}
//	else if ([url rangeOfString:@"identifier=likes"].length > 0.0) {
//		//NSLog(@"likes: %@", result);
//		if ([_delegate respondsToSelector:@selector(socialFacebook:DidReceiveNumberOfLikes:)]) {
//			[_delegate socialFacebook:self DidReceiveNumberOfLikes:[NSString stringWithFormat:@"%@", [result objectForKey:@"likes"]]];
//		}
//	}
//	else if ([url rangeOfString:@"identifier=pagelike"].length > 0.0) {
//		//NSLog(@"result: %@", result);
//		if ([_delegate respondsToSelector:@selector(socialFacebookDidLike:)]) {
//			[_delegate socialFacebookDidLike:self];
//		}
//	}
//    }
//    [_fbRequests removeObject:request];
//    [self releaseRequestObjects];
}


-(void) performPendingAction {
	if (pendingAction == @selector(shareFeed:WithComment:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"post"] withObject:[pendingActionParams objectForKey:@"comment"]];
	}
	else if (pendingAction == @selector(handleLike:) || pendingAction == @selector(handleUnlike:)){
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"postId"]];
	}
	//else if (pendingAction == @selector(handleComment:InPost:)) {
	//	[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"comment"] withObject:[pendingActionParams objectForKey:@"postId"]];
	//}
	else if (pendingAction == @selector(createEvent:)){
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"event"]];
	}
	else if (pendingAction == @selector(inviteFriendsToEvent:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"event"]];
	}
	else if (pendingAction == @selector(listFriendsOfLoggedUser:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"pageSize"]];
	}
	else if (pendingAction == @selector(eventMarkAttending:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"eventId"]];
	}
	else if (pendingAction == @selector(getEvent:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"eventId"]];
	}
	else if (pendingAction == @selector(getInvitedUsersForEvent:PageSize:)) {
		[self performSelector:pendingAction withObject:[pendingActionParams objectForKey:@"eventId"] withObject:[pendingActionParams objectForKey:@"pageSize"]];
	}
}


#pragma mark - FBSessionDelegate methods
/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    SFDLog(@"User logged in");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    SFDLog(@"Access token info saved");
    
    if (_loginBlock) {
        _loginBlock();
        [_loginBlock release], _loginBlock = nil;
    }
    
    if (_notLoginBlock) {
        [_notLoginBlock release], _notLoginBlock = nil;
    }

}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    SFDLog(@"Did not login. User cancelled: %@", (cancelled? @"YES" : @"NO"));
    
    if (_loginBlock) {
        [_loginBlock release], _loginBlock = nil;
    }
    
    if (_notLoginBlock) {
        _notLoginBlock(cancelled);
        [_notLoginBlock release], _notLoginBlock = nil;
    }
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
	SFDLog(@"Logout");
    
    [self clearUserInfo];
    
    if (_logoutBlock) {
        _logoutBlock();
        [_logoutBlock release], _logoutBlock = nil;
    }
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired 
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    SFDLog(@"Session invalidated");
    
    [self clearUserInfo];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Quit the app
    exit(1);
}

#pragma mark - Dealloc

- (void) dealloc
{
	[_facebook release];
	[_appId release];
    [_appSecret release];
    [_permissions release];
    [_appAccessToken release];
    
    [shingleServerPath release];
	[pendingActionParams release];
	[nextPageInvited release];
	[nextPageFriends release];
	[facebookUserId release];
	[loggedUserId release];
    
	SFDLog(@"SFSocialFacebook deallocated");
    
	[super dealloc];
}

@end
