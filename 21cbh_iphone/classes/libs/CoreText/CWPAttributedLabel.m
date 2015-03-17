//
//  CWPAttributedLabel.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPAttributedLabel.h"

@implementation CWPAttributedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgInfoDicArray_ = [NSMutableArray array];
        images_ = [NSMutableArray array];
    }
    return self;
}

-(void)setAttString:(NSAttributedString *)string withImages:(NSMutableArray *)imgs
{
    images_=imgs;
    [self setAttributedText:string];
}

-(void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
}

-(void)attachImagesWithFrame:(CTFrameRef)f
{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [images_ objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=images_.count) return; //quit if no images for this column
        nextImage = [images_ objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { //7
	            CGRect runBounds;
	            CGFloat ascent;//height above the baseline
	            CGFloat descent;//height below the baseline
	            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
	            runBounds.size.height = ascent + descent;
                
	            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
	            runBounds.origin.x = origins[lineIndex].x  + xOffset;
	            runBounds.origin.y = origins[lineIndex].y;
	            runBounds.origin.y -= descent;
                NSString *urlStr = [nextImage objectForKey:@"fileName"];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                CGRect mirrorBounds = CGRectMake(imgBounds.origin.x, self.bounds.size.height-imgBounds.origin.y-imgBounds.size.height, imgBounds.size.width, imgBounds.size.height);// y方向imgBounds的镜像
                [imgInfoDicArray_ addObject: //11
                 [NSArray arrayWithObjects:urlStr, NSStringFromCGRect(imgBounds), NSStringFromCGRect(mirrorBounds), nil]];
                //load the next image //12
                imgIndex++;
                if (imgIndex < images_.count) {
                    nextImage = [images_ objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
            }
        }
        lineIndex++;
    }
}

@end
