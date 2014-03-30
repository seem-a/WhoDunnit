//
//  WDInvitationsTableViewCell.m
//  WhoDunnit
//
//  Created by me on 30/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDInvitationsTableViewCell.h"

@implementation WDInvitationsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
       
        
        
    }
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

#pragma mark IBActions

- (IBAction)acceptButtonPressed:(UIButton *)sender {
    [self.delegate acceptInvitation:self.indexPath];
}

- (IBAction)rejectButtonPressed:(UIButton *)sender {
    [self.delegate rejectInvitation:self.indexPath];
}






@end
