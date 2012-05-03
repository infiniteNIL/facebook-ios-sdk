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

#import "ObjectPickerController.h"
#import "SFSimpleUser.h"
#import "SFEvent.h"
#import "SFComment.h"

@interface ObjectPickerController (Private)

- (void)doneButtonClicked:(UIBarButtonItem *)button;

@end

@implementation ObjectPickerController

- (id)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy @HH:mm"];
    }
    return self;
}

- (id)initWithObjects:(NSArray *)objects type:(ObjectType)type pickerType:(ObjectPickerType)pickerType completion:(ObjectPickerCompletionBlock)completionBlock
{
    self = [self init];
    if (self) {
        _type = type;
        _pickerType = pickerType;
        _completionBlock = [completionBlock copy];
        _objects = [objects retain];
        _selectedObjects = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_completionBlock release];
    [_tableView release];
    [_objects release];
    [_selectedObjects release];
    [_dateFormatter release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    switch (_type) {
        case ObjectTypeUser:
            self.navigationItem.title = @"Users";
            break;
        case ObjectTypeEvent:
            self.navigationItem.title = @"Events";
            break;
        case ObjectTypeComment:
            self.navigationItem.title = @"Comments";
            break;
        default:
            break;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:[self.view bounds] style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    switch (_pickerType) {
        case ObjectPickerTypeNone:
            [_tableView setAllowsSelection:NO];
            break;
        case ObjectPickerTypeOne:
            break;
        case ObjectPickerTypeMany:
        {
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
            self.navigationItem.rightBarButtonItem = doneButton;
            [doneButton release];
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload
{
    [_tableView release], _tableView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private

- (void)doneButtonClicked:(UIBarButtonItem *)button
{
    if (_completionBlock) {
        _completionBlock([_selectedObjects allKeys]);
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFObject *object = [_objects objectAtIndex:indexPath.row];
    
    if (_pickerType == ObjectPickerTypeOne) {
        if (_completionBlock) {
            _completionBlock([NSArray arrayWithObject:[object objectId]]);
        }
    } else {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([_selectedObjects objectForKey:[object objectId]]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [_selectedObjects removeObjectForKey:[object objectId]];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [_selectedObjects setObject:object forKey:[object objectId]];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
    }
    
    switch (_type) {
        case ObjectTypeUser:
        case ObjectTypeEvent:
        {
            SFObject *object = [_objects objectAtIndex:indexPath.row];
            
            cell.accessoryType = ([_selectedObjects objectForKey:[object objectId]])? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.textLabel.text = object.name;
            
            if (_type == ObjectTypeEvent) {
                SFEvent *event = (SFEvent *)object;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ~ %@", [_dateFormatter stringFromDate:[event startTime]], [_dateFormatter stringFromDate:[event endTime]]];
            } else {
                //        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[object pictureUrl]]]];
            }
        }
            break;
        case ObjectTypeComment:
        {
            SFComment *object = [_objects objectAtIndex:indexPath.row];
            
            cell.textLabel.text = object.from.name;
            cell.detailTextLabel.text = object.message;

        }
            break;
        default:
            break;
    }
    
    return cell;
}

@end
