//
//  SFURLRequest.h
//  facebook-ios-sdk
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
}

- (id)initWithURL:(NSString *)url
          success:(void (^)(NSData *receivedData))successBlock
          failure:(void (^)(NSError *error))failureBlock;

- (void)cancel;

@end
