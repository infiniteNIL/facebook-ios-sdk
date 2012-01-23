//
//  ObjectPickerController.h
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/16/12.
//  Copyright (c) 2012 I.ndigo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ObjectTypeUser, 
    ObjectTypeEvent, 
    ObjectTypeComment, 
} ObjectType;

typedef enum {
    ObjectPickerTypeNone,
    ObjectPickerTypeOne,
    ObjectPickerTypeMany,
} ObjectPickerType;

typedef void (^ObjectPickerCompletionBlock)(NSArray *selectedIds);

@interface ObjectPickerController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    ObjectType _type;
    ObjectPickerType _pickerType;
    ObjectPickerCompletionBlock _completionBlock;
    
    UITableView *_tableView;
    
    NSArray *_objects;
    NSMutableDictionary *_selectedObjects;
    
    NSDateFormatter *_dateFormatter;
}

- (id)initWithObjects:(NSArray *)objects type:(ObjectType)type pickerType:(ObjectPickerType)pickerType completion:(ObjectPickerCompletionBlock)completionBlock;

@end
