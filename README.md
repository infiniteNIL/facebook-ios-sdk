SFSocialFacebook
================

This is a Facebook SDK Façade for iOS with Blocks. SFSocialFacebook is a fork of [Facebook SDK for iOS](https://github.com/facebook/facebook-ios-sdk) with simpler and cleaner way to use.

Installation
------------

### CocoaPod

    dependency SFSocialFacebook, ~> '1.1.0'

### Non-CocoaPod

Copy all files from `src/` except `.xcodeproj`and `.pch` files to your project.

Setup
-----

In your project's `AppDelegate.m`:

    objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"create_event", @"user_events", @"rsvp_event", @"publish_stream", nil];
    _socialFacebook = [SFSocialFacebook sharedInstanceWithAppId:@"YOUR_APP_ID" appSecret:@"YOUR_APP_SECRET" urlSchemeSuffix:nil andPermissions:permissions];
    [permissions release];
    ...
    }
    
    // Pre 4.2 support
    - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
        return [_socialFacebook handleOpenURL:url];
    }
    
    // For 4.2+ support
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
        return [_socialFacebook handleOpenURL:url];
    }

Sample Application
------------------

There is a sample XCode project using SFSocialFacebook in `sample/SFSocialFacebookExample/SFSocialFacebookExample.xcodeproj`.

License
-------

SFSocialFacebook is licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0).

Copyright 2012 I.ndigo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.