//
//  WDItemsTableViewCell.h
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDItem.h"

@protocol WDItemsTableViewCellDelegate <NSObject>

-(void) itemDeleted:(WDItem *)item;
-(void) itemCompleted:(WDItem *)item;

@end


@interface WDItemsTableViewCell : UITableViewCell

@property (nonatomic) WDItem *item;
@property (weak, nonatomic) id <WDItemsTableViewCellDelegate> delegate;

@end
