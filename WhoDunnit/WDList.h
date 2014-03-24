//
//  WDList.h
//  WhoDunnit
//
//  Created by me on 16/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDList : NSObject

@property (strong, nonatomic) NSString *listID;
@property (strong, nonatomic) NSString *name;


-(id)initWithName:(NSString*)name andListID:(NSString*)listID;

+(id)itemWithName:(NSString*)name andListID:(NSString*)listID;


@end
