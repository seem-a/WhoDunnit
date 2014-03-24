//
//  WDItemsTableViewCell.m
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import "WDItemsTableViewCell.h"
#import "WDStrikeThroughLabel.h"

#define LABEL_LEFT_MARGIN 15;

@interface WDItemsTableViewCell() <UIGestureRecognizerDelegate>

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) BOOL deleteOnDragRelease;
@property (nonatomic) bool markCompleteOnDragRelease;

@end

@implementation WDItemsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // add a pan recognizer
        UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
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

#pragma mark - horizontal pan gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    
    // 1
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        self.originalCenter = self.center;
    }
    
    // 2
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(self.originalCenter.x + translation.x, self.originalCenter.y);
        
        // determine whether the item has been dragged right to initiate a complete
        self.markCompleteOnDragRelease = self.frame.origin.x > 0 || self.frame.origin.x < 0;
        
        // determine whether the item has been dragged far enough right to initiate a delete
        self.deleteOnDragRelease = self.frame.origin.x > self.frame.size.width * 3/4;
    }
    
    // 3
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);

        if (self.deleteOnDragRelease)
        {
            [self.delegate itemDeleted:self.item];
        }
        else if (self.markCompleteOnDragRelease)
        {
            //update item completed
            [self.delegate itemCompleted:self.item];
            
            //snap back to the original location
            [self snapBack:originalFrame];
        }
    }
}


- (void)snapBack:(CGRect)frame
{
    // if the item is not being deleted or completed, snap back to the original location
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    }];
    
}





@end
