//
//  WDListsTableViewCell.m
//  WhoDunnit
//
//  Created by me on 17/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDListsTableViewCell.h"

@implementation WDListsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
//    [self.superview recursiveDescription];
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
