//
//  TimelineViewController.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/3/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFFacebookRequest;


@interface TimelineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *_posts;
    NSString *_nextPageURL;
    UITableView *_tableView;
    UIBarButtonItem *_nextPageButton;
    SFFacebookRequest *_facebookRequest;
}

@end
