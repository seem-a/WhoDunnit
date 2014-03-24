//
//  WDList.m
//  WhoDunnit
//
//  Created by me on 16/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDList.h"

@implementation WDList

-(id)initWithName:(NSString*)name andListID:(NSString*)listID
{
    if (self = [super init]) {
        self.name = name;
        self.listID = listID;
    }
    return self;

}

+(id)itemWithName:(NSString*)name andListID:(NSString*)listID{
    return [[WDList alloc] initWithName:name andListID:listID];
}

@end
