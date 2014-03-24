//
//  WDItem.h
//  WhoDunnit
//
//  Created by me on 16/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDItem : NSObject

@property (strong, nonatomic) NSString *itemID;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *listID;
@property (nonatomic) BOOL IsDone;

-(id)initWithText:(NSString*)text andItemID:(NSString*)itemID andListID:(NSString *)listID andIsDone:(BOOL)isDone;

+(id)itemWithText:(NSString*)text andItemID:(NSString*)itemID andListID:(NSString *)listID andIsDone:(BOOL)isDone;

@end
