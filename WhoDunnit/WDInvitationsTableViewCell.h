//
//  WDInvitationsTableViewCell.h
//  WhoDunnit
//
//  Created by me on 30/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WDInvitationsTableViewCellDelegate <NSObject>

-(void)acceptInvitation:(NSIndexPath *)indexPath;
-(void)rejectInvitation:(NSIndexPath *)indexPath;

@end

@interface WDInvitationsTableViewCell : UITableViewCell

@property (weak, nonatomic) id <WDInvitationsTableViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *invitationText;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
