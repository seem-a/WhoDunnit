//
//  WDItemsTableViewCellDelegate.h
//  WhoDunnit
//
//  Created by me on 16/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WDItem.h"

// A protocol that the WDItemsTableViewCell uses to inform of state change
@protocol WDItemsTableViewCellDelegate <NSObject>

// indicates that the given item has been deleted
-(void) itemDeleted:(WDItem*)item;

@end
