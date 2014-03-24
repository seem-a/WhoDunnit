//
//  WDItem.m
//  WhoDunnit
//
//  Created by me on 16/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDItem.h"

@implementation WDItem


-(id)initWithText:(NSString*)text andItemID:(NSString*)itemID andListID:(NSString *)listID andIsDone:(BOOL)isDone
{
    if (self = [super init]) {
        self.text = text;
        self.itemID = itemID;
        self.listID = listID;
        self.IsDone = isDone;
    }
    return self;
}

+(id)itemWithText:(NSString *)text andItemID:(NSString*)itemID andListID:(NSString *)listID andIsDone:(BOOL)isDone
{
    return [[WDItem alloc] initWithText:text andItemID:itemID andListID:listID andIsDone:isDone];
}

@end
