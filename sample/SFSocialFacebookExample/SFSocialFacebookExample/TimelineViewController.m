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

#import "TimelineViewController.h"
#import "SFSocialFacebook.h"
#import "APICallViewController.h"

@interface TimelineViewController (Private)

- (void)refreshButtonClicked:(UIBarButtonItem *)button;
- (void)nextPageButtonClicked:(UIBarButtonItem *)button;

@end

@implementation TimelineViewController

- (id)init {
    self = [super init];
    if (self) {
        _posts = [[NSMutableArray alloc] init];
        _profileId = @"indigotest";
        _needsLogin = NO;
    }
    return self;
}

- (void)dealloc
{
    [_facebookRequest cancel];
    
    [_posts release];
    [_nextPageURL release];
    [_tableView release];
    [_nextPageButton release];
    [_facebookRequest release];
    [_profileId release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.navigationItem.title = _profileId;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _nextPageButton = [[UIBarButtonItem alloc] initWithTitle:@"Next Page" style:UIBarButtonItemStyleDone target:self action:@selector(nextPageButtonClicked:)];
    
    self.toolbarItems = [NSArray arrayWithObjects:space, _nextPageButton, nil];
    [space release];
    
    _tableView = [[UITableView alloc] initWithFrame:[self.view bounds] style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [self refreshButtonClicked:refreshButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release], _facebookRequest = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{   
    [_nextPageURL release], _nextPageURL = nil;
    [_tableView release], _tableView = nil;
    [_nextPageButton release], _nextPageButton = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private

- (void)refreshButtonClicked:(UIBarButtonItem *)button
{
    [_posts removeAllObjects];
    [_tableView reloadData];
    
    [_nextPageURL release], _nextPageURL = nil;
    [button setEnabled:NO];
    [_nextPageButton setEnabled:NO];
    
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] profileFeed:_profileId 
                                                                  pageSize:5 
                                                                needsLogin:_needsLogin
                                                                   success:^(NSArray *posts, NSString *nextPageUrl) {
                                                                       [_posts addObjectsFromArray:posts];
                                                                       [_tableView reloadData];
                                                                       [_nextPageURL release];
                                                                       _nextPageURL = [nextPageUrl copy];
                                                                       [button setEnabled:YES];
                                                                       [_nextPageButton setEnabled:(_nextPageURL != nil)];
                                                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                   }
                                                                   failure:^(NSError *error) {
                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                       [alert show];
                                                                       [alert release];
                                                                       [button setEnabled:YES];
                                                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                   } cancel:^{
                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Feed request was cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                       [alert show];
                                                                       [alert release];
                                                                       [button setEnabled:YES];
                                                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                   }] retain];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)nextPageButtonClicked:(UIBarButtonItem *)button
{
    [button setEnabled:NO];
    
    if (_facebookRequest) {
        [_facebookRequest cancel];
        [_facebookRequest release];
    }
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] profileFeedNextPage:_nextPageURL 
                                                                          success:^(NSArray *posts, NSString *nextPageUrl) {
                                                                              [_posts addObjectsFromArray:posts];
                                                                              [_tableView reloadData];
                                                                              [_nextPageURL release];
                                                                              _nextPageURL = [nextPageUrl copy];
                                                                              [button setEnabled:(_nextPageURL != nil)];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          } failure:^(NSError *error) {
                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                              [alert show];
                                                                              [alert release];
                                                                              [button setEnabled:YES];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          } cancel:^{
                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Feed next page request was cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                              [alert show];
                                                                              [alert release];
                                                                              [button setEnabled:YES];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          }] retain];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFSimplePost *post = [_posts objectAtIndex:indexPath.row];
    
    UIViewController *ctrl = [[APICallViewController alloc] initWithMenu:@"post" andObjectId:post.objectId];
    [self.navigationController pushViewController:ctrl animated:YES];
    [ctrl release];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
    }
    
    SFSimplePost *post = [_posts objectAtIndex:[indexPath row]];
    cell.textLabel.text = post.from.name;
    cell.detailTextLabel.text = post.message;
    
    return cell;
}

@end
