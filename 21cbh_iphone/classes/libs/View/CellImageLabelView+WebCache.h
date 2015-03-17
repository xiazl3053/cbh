//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CellImageLabelView.h"
#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

@interface CellImageLabelView (WebCache) <SDWebImageManagerDelegate>

/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url that the image is found.
 * @see setImageWithURL:placeholderImage:
 */
- (void)requestImage;

/**
 * Cancel the current download
 */
- (void)cancelCurrentImageLoad;

@end
