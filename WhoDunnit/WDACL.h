//
//  WDACL
//  WhoDunnit
//
//  Created by me on 23/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDACL : PFACL

+ (PFACL *)roleACL;

+ (PFACL *)listACL:(PFRole *)role;

@end
