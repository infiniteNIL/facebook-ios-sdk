//
//  Menus.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menus : NSObject

+ (Menus *)sharedInstance;

- (NSArray *)main;
- (NSArray *)login;
@end
