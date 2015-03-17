//
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "AGShareCell.h"

#define IMAGE_SIZE 35.0

@implementation AGShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat vg = (self.contentView.height - IMAGE_SIZE) / 2;
    
    self.imageView.frame = CGRectMake(vg, vg, IMAGE_SIZE, IMAGE_SIZE);
    self.textLabel.frame = CGRectMake(self.imageView.left + self.imageView.width + vg, self.textLabel.top, self.textLabel.width, self.textLabel.height);
}

@end
