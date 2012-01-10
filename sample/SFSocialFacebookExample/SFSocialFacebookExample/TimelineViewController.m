//
//  TimelineViewController.m
//  SFSocialFacebookExample
//
//  Created by Massaki on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "SFSocialFacebook.h"

@interface TimelineViewController (Private)

- (void)refreshButtonClicked:(UIBarButtonItem *)button;
- (void)nextPageButtonClicked:(UIBarButtonItem *)button;

@end

@implementation TimelineViewController

- (id)init {
    self = [super init];
    if (self) {
        _posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_posts release];
    [_nextPageURL release];
    [_tableView release];
    [_nextPageButton release];
    [_facebookRequest release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.navigationItem.title = @"stanfordfootball";
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
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] listProfileFeed:@"stanfordfootball" 
                                                                  pageSize:5 
                                                                needsLogin:NO
                                                                   success:^(NSArray *posts, NSString *nextPageURL) {
                                                                       [_posts addObjectsFromArray:posts];
                                                                       [_tableView reloadData];
                                                                       [_nextPageURL release];
                                                                       _nextPageURL = [nextPageURL copy];
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
                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request cancelled" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    _facebookRequest = [[[SFSocialFacebook sharedInstance] listProfileFeedNextPage:_nextPageURL 
                                                                          success:^(NSArray *posts, NSString *nextPageURL) {
                                                                              [_posts addObjectsFromArray:posts];
                                                                              [_tableView reloadData];
                                                                              [_nextPageURL release];
                                                                              _nextPageURL = [nextPageURL copy];
                                                                              [button setEnabled:(_nextPageURL != nil)];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          } failure:^(NSError *error) {
                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                              [alert show];
                                                                              [alert release];
                                                                              [button setEnabled:(_nextPageURL != nil)];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          } cancel:^{
                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request cancelled" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                              [alert show];
                                                                              [alert release];
                                                                              [button setEnabled:(_nextPageURL != nil)];
                                                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                          }] retain];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - UITableViewDelegate


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
    [[cell textLabel] setText:[post userName]];
    [[cell detailTextLabel] setText:[post message]];
    return cell;
}

@end
