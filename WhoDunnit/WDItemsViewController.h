//
//  WDItemsTableViewController.h
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDList.h"

@interface WDItemsViewController : UIViewController

@property (strong, nonatomic) WDList *list;
@property (nonatomic) int invitationsCount;

@end
