//
//  WDACL
//  WhoDunnit
//
//  Created by me on 23/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDACL.h"

@implementation WDACL

+ (PFACL *)roleACL
{
    //Readonly privileges.
    PFACL *roleACL = [PFACL ACL];
    [roleACL setPublicReadAccess:YES];
    
    return roleACL;
}

+ (PFACL *)listACL:(PFRole *)role
{
    //grant write privileges to role
    PFACL *listACL = [PFACL ACL];
    [listACL setPublicReadAccess:NO];
    [listACL setReadAccess:YES forRole:role];
    [listACL setWriteAccess:YES forRole:role];

    return listACL;
}

@end
