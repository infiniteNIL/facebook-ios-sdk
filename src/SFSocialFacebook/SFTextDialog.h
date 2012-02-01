//
//  SFTextDialog.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/30/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import "FBDialog.h"

@class SFURLRequest;
@class SFFacebookRequest;


@interface SFTextDialog : FBDialog <UITextViewDelegate> {
    UINavigationBar     *_navigationBar;
    UITextView          *_textView;
    BOOL                _noComment;
    SFURLRequest        *_pictureRequest;
    SFFacebookRequest   *_appInfoRequest;
    UIImageView         *_iconView;
    UILabel             *_viaLabel;
    
}

- (void)dismiss:(BOOL)animated;

@property(nonatomic, copy) NSString *placeHolder;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) void (^successBlock)(NSString *message);
@property(nonatomic, copy) void (^cancelBlock)();

@end
