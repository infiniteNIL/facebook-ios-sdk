//
//  SFSimplePost.m
//  SFSocialFacebook
//
//  Created by Massaki on 1/10/12.
//  Copyright (c) 2011 I.ndigo. All rights reserved.
//

#import "SFSimplePost.h"


@implementation SFSimplePost

@synthesize postId;
@synthesize userId;
@synthesize userName;
@synthesize userImageUrl;
@synthesize message;
@synthesize picture;
@synthesize link;
@synthesize name;
@synthesize caption;
@synthesize postDescription;
@synthesize source;
@synthesize type;
@synthesize numLikes;
@synthesize numComments;
@synthesize comments;
@synthesize createdTime;
@synthesize updatedTime;
@synthesize to;
@synthesize actionName;
@synthesize actionLink;

#pragma mark - Methods

- (id)init {
	if ((self = [super init])) {
		_userLikesIt = NO;
	}
	return self;
}

- (BOOL)userLikesIt {
	return _userLikesIt;
}


- (NSString *)getIntervalDescriptionFromCreationDate {
	int timeDifference = (int)[[self createdTime] timeIntervalSinceNow];
	NSString *description;
	
	timeDifference = (-1) * timeDifference / 60; // Minutes
	
	if (timeDifference >= 60) {
		timeDifference = timeDifference / 60; // Hours
		
		if (timeDifference >= 24) {
			timeDifference = timeDifference / 24; // Days
			if (timeDifference == 1) {
				description = [NSString stringWithFormat:@"about a day ago"];
			}
			else if (timeDifference < 7) {
				description = [NSString stringWithFormat:@"%d days ago", timeDifference];
			}
			else if (timeDifference == 7) {
				description = [NSString stringWithFormat:@"about a week ago"];
			}
			else if (timeDifference < 30) {
				timeDifference = timeDifference / 7; // Weeks
				description = [NSString stringWithFormat:@"%d weeks ago", timeDifference];
			}
			else if (timeDifference < 60) {
				description = [NSString stringWithFormat:@"about a month ago"];
			}
			else if (timeDifference < 365) {
				timeDifference = timeDifference / 30; // Months
				description = [NSString stringWithFormat:@"%d months ago", timeDifference];
			}
			else if (timeDifference < 730) {
				description = [NSString stringWithFormat:@"about a year ago"];
			}
			else{
				timeDifference = timeDifference / 365; // Years
				description = [NSString stringWithFormat:@"%d years ago", timeDifference];
			}
		}
		else {
			if (timeDifference == 1) {
				description = [NSString stringWithFormat:@"about a hour ago"];
			}
			else {
				description = [NSString stringWithFormat:@"%d hours ago", timeDifference];
			}

		}

	}
	else {
		if (timeDifference == 1) {
			description = [NSString stringWithFormat:@"about a minute ago"];
		}
		else {
			description = [NSString stringWithFormat:@"%d minutes ago", timeDifference];
		}
	}

	return description;
}

#pragma mark - Dealloc

- (void)dealloc {
	[postId release];
	[userId release];
	[userName release];
	[userImageUrl release];
	[message release];
	[picture release];
	[link release];
	[name release];
	[caption release];
	[postDescription release];
	[source release];
	[type	release];
	[numLikes release];
	[numComments release];
	[comments release];
    [createdTime release];
    [updatedTime release];
    [to release];
    
    [super dealloc];
}

@end
