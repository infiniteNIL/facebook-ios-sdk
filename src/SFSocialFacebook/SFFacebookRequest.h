//
//  SFFacebookRequest.h
//  facebook-ios-sdk
//
//  Created by Massaki on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"

@class Facebook;

@interface SFFacebookRequest : NSObject <FBRequestDelegate> {
    
    // Blocks
    void (^_successBlock)(id);
    void (^_failureBlock)(NSError *);
}

- (id)initWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

+ (SFFacebookRequest *)requestWithFacebook:(Facebook *)facebook graphPath:(NSString *)graphPath success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

@end
