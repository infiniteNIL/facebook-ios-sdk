/*
 * Copyright 2012 I.ndigo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
