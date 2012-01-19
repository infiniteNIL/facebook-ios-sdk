//
//  SFURLRequest.h
//  SFSocialFacebook
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFURLRequest : NSObject <NSURLConnectionDataDelegate> {
    
    NSURLConnection     *_connection;
    NSMutableData       *_receivedData;
    
    // Blocks
    void (^_successBlock)(NSData *);
    void (^_failureBlock)(NSError *);
    void (^_cancelBlock)();
}

+ (id)requestWithURL:(NSString *)url success:(void (^)(NSData *receivedData))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;

- (id)initWithURL:(NSString *)url success:(void (^)(NSData *receivedData))successBlock failure:(void (^)(NSError *error))failureBlock cancel:(void (^)())cancelBlock;

- (void)cancel;

@end
