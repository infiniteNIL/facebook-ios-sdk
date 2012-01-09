//
//  SFUtil.h
//  Hackbook
//
//  Created by Massaki on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#   define SFDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define SFDLog(...)
#endif

#define SFError(description) [NSError errorWithDomain:@"br.com.indigo.social.SFSocialFacebook" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil]]
