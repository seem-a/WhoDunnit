//
//  WDStrikeThroughLabel.m
//  WhoDunnit
//
//  Created by me on 15/03/14.
//  Copyright (c) 2014 iDoodle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WDStrikeThroughLabel.h"

#define STRIKEOUT_THICKNESS 2.0f

@interface WDStrikeThroughLabel()

@property (strong, nonatomic) CALayer *strikethroughLayer;

@end

@implementation WDStrikeThroughLabel

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.strikethroughLayer = [CALayer layer];
        self.strikethroughLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.strikethroughLayer.hidden = YES;
        [self.layer addSublayer:_strikethroughLayer];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self resizeStrikeThrough];
}

-(void)setText:(NSString *)text {
    [super setText:text];
    [self resizeStrikeThrough];
}

// resizes the strikethrough layer to match the current label text
-(void)resizeStrikeThrough {

    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    self.strikethroughLayer.frame = CGRectMake(0, self.bounds.size.height/2,
                                           textSize.width, STRIKEOUT_THICKNESS);
}

#pragma mark - property setter
-(void)setStrikethrough:(bool)strikethrough {
    self.strikethrough = strikethrough;
    self.strikethroughLayer.hidden = !strikethrough;
}

@end
