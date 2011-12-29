//
//  SFAuthorization.h
//  NBC
//
//  Created by Bruno Nigro on 29/04/11.
//  Copyright 2011 Indigo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFAuthorization : NSObject {
    bool _logged;
    NSString *_token;
    NSDate *_expirationDate;
}
+ (SFAuthorization *)sharedInstance;

@property (nonatomic) bool logged;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSDate *expirationDate;

@end
