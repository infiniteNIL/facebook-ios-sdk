//
//  APICallViewController.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/5/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFURLRequest;
@class SFFacebookRequest;

@interface APICallViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    NSArray *_menuOptions;
    NSString *_objectId;
    
    SFURLRequest *_urlRequest;
    SFFacebookRequest *_facebookRequest;
}

- (id)initWithMenu:(NSString *)menu;
- (id)initWithMenu:(NSString *)menu andObjectId:(NSString *)objectId;

@end
