//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CellImageLabelView+WebCache.h"
#import "UIImage+Custom.h"

@implementation CellImageLabelView (WebCache)

-(void)requestImage
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [manager downloadWithURL:[NSURL URLWithString:iCellData.imageUrl] delegate:self];
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if(iCellData.imageCornerRadius>0)
    {
        image=[image imageWithCornerRadius:iCellData.imageCornerRadius];
        iCellData.imageCornerRadius=0;
    }
    
    iImageView.image = image;
    iImageView.contentMode=UIViewContentModeScaleAspectFit;
    iCellData.imageUrl=nil;
    iCellData.iImage=image;
}

@end
