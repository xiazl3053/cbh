//
//  CollectCustomView.m
//  21cbh_iphone
//
//  Created by qinghua on 14-4-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CollectCustomView.h"
#import <CoreText/CoreText.h>

@implementation CollectCustomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"init===Rect=%@",NSStringFromCGRect(frame));
        self.backgroundColor=[UIColor blueColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"---------drwaRect---------");
    //创建要输出的字符串f
    NSString *longText = @"３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部３月２２日至４月１日，国家主席习近平对荷兰、法国、德国、比利时进行国事访问，出席在荷兰海牙举行的核安全峰会，并访问联合国教科文组织总部和欧盟总部";
    
    
    //创建AttributeStringfdsa
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                         initWithString:longText];

    //换行模式
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;//kCTLineBreakByWordWrapping;//换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
  
    
    //创建文本对齐方式
    CTTextAlignment alignment = kCTLeftTextAlignment;//kCTNaturalTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    //行距
    CGFloat _linespace = 10.0f;
    CTParagraphStyleSetting lineSpaceSetting;
    lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceSetting.value = &_linespace;
    lineSpaceSetting.valueSize = sizeof(float);
    
    
    //组合设置
    CTParagraphStyleSetting settings[] = {
        lineBreakMode,
         alignmentStyle,
        lineSpaceSetting,
    };
    
    //通过设置项产生段落样式对象
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 3);
    
    // build attributes
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
    
    // set attributes to attributed string
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    
    CGMutablePathRef Path = CGPathCreateMutable();
    
    //坐标点在左下角
    CGPathAddRect(Path, NULL ,CGRectMake(10 , 0 ,self.bounds.size.width-20 , self.bounds.size.height-20));
    
    CGFloat height=[self getAttributedStringHeightWithString:string WidthValue:300];
    
    NSLog(@"height=%f",height);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    
    self.frame=CGRectMake(0, 64, 300, height);
    
    
    // flip the coordinate system
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
    
    // draw
    CTFrameDraw(frame, context);
    
    // cleanup
    
   // CGPathRelease(leftColumnPath);
    CFRelease(framesetter);
    //CFRelease(helvetica);
    // CFRelease(helveticaBold);
    
    UIGraphicsPushContext(context);

    
}

- (int)getAttributedStringHeightWithString:(NSAttributedString *)  string  WidthValue:(int) width
{
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
    
}


@end
