//
//  SFAuthorization.m
//  NBC
//
//  Created by Bruno Nigro on 29/04/11.
//  Copyright 2011 Indigo. All rights reserved.
//

#import "SFAuthorization.h"


@implementation SFAuthorization

@synthesize logged = _logged;
@synthesize token = _token;
@synthesize expirationDate = _expirationDate;

static SFAuthorization *_instance;

+ (SFAuthorization *)sharedInstance {
    
	@synchronized(self) {
        
        if (_instance == nil) {
            
            _instance = [[super allocWithZone:NULL] init];
            
        }
    }
    return _instance;
    
}

- (id) init
{
    self = [super init];
    if(self)
        _logged = false;
    return self;
}

@end
