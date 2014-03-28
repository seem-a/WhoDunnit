//
//  WDListsTableViewCell.h
//  WhoDunnit
//
//  Created by me on 17/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDList.h"

@protocol WDListsTableViewCellDelegate <NSObject>

- (void)leaveList:(WDList *)list;

@end



@interface WDListsTableViewCell : UITableViewCell

@property (nonatomic) WDList *list;
@property (weak, nonatomic) id <WDListsTableViewCellDelegate> delegate;

@end
