//
//  SFFacebookRequest.h
//  SFSocialFacebook
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"

@class Facebook;


@interface SFFacebookRequest : NSObject <FBRequestDelegate> {
    
    FBRequest *_request;
    BOOL _isFinished;
    
    // Blocks
    void (^_successBlock)(id);
    void (^_failureBlock)(NSError *);
    void (^_cancelBlock)(void);
}

+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
+ (id)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;
- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod needsLogin:(BOOL)needsLogin success:(void (^)(id result))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;

- (void)cancel;

@end
