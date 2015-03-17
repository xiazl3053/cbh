//
//  FMTextView.m
//  Liuxue
//
//  Created by zhaomingxi on 14-1-30.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

//_fmString = @"中文图片[img]http://t5.zbjimg.com/t5s/lib/img/2014_hello.pngkdfjkdjfkdjfk dkfj[/img]看见看见 我是来自 那个星球的下图片  [img]1.png[/img]哈哈结束了 ";

#import "FMTextView.h"
#import <CoreText/CoreText.h>

#define imageStartTag @"[img]" // 图片开始标签
#define imageEndTag @"[/img]" // 图片结束标签
#define imageType @".jpg,.png,.bmp,.gif";


@interface FMTextView(){
    NSString* _fmString; // 内容
    NSMutableArray *_fmArray;//根据图片切割后存储所用到的数组
    NSMutableArray *_fmIsImage;// 对应的分割字符串是否是图片
    NSMutableString *_newString ;// 重组后的内容
    // 用于IOS6.0以下
    CGContextRef _context;
    CGFloat _fmHeight;
}

@end


@implementation FMTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(id)init{
    self = [super init];
    if (self) {
        self.fmDefaultImageSize = CGSizeMake(self.frame.size.width,180);
        self.fmImages = [[NSMutableDictionary alloc] init];
        _newString = [[NSMutableString alloc] init];
        self.scrollEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.editable = NO;
        self.isStrHeight = YES;
        self.lineHeight = 10;// 默认行高为3；
        self.currentPoint = CGPointMake(0, 0); // 图片y轴的定位，默认为0；
        self.contentInset = UIEdgeInsetsZero;
        self.backgroundColor = [UIColor clearColor];
        
        _fmHeight = 0;
    }
    return self;
}



-(void)setText:(NSString *)text{
    _fmString = text;
    
    [self splitString];
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=6){
        // 设置行高
        self.lineHeight = self.font.pointSize+self.lineHeight;
        // 开始画图 6_0  7_0
        for (NSString *item in _fmArray) {
            BOOL isImage = [[_fmIsImage objectAtIndex:[_fmArray indexOfObject:item]] floatValue];
            // 如果是6.0就用原生态text来显示
            [self characterAttribute:item andIsImage:isImage];
        }
        if (!_newString) {
            _newString = [[NSMutableString alloc] initWithString:_fmString];
        }
        // 设置对齐方式和行高等
        NSMutableParagraphStyle *textViewparagraphStyle = [[NSMutableParagraphStyle alloc] init];
        textViewparagraphStyle.lineHeightMultiple = self.lineHeight;
        textViewparagraphStyle.maximumLineHeight = self.lineHeight;
        textViewparagraphStyle.minimumLineHeight = self.lineHeight;
        textViewparagraphStyle.lineBreakMode = kCTParagraphStyleSpecifierAlignment;
        // 对齐方式
        CTTextAlignment ctAlignment = kCTJustifiedTextAlignment;
        NSTextAlignment lineAlignment = NSTextAlignmentFromCTTextAlignment(ctAlignment);
        textViewparagraphStyle.alignment = lineAlignment;
        
        // 组装属性为字典
        NSDictionary *attribute = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.font,
                                   NSFontAttributeName,
                                   textViewparagraphStyle,
                                   NSParagraphStyleAttributeName, nil];
        // 设置文本属性
        self.attributedText = [[NSMutableAttributedString alloc] initWithString:_newString attributes:attribute];
        super.text = _newString;
        //[self sizeToFit];
        //self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }else{
        // 计算drawview的高度 5_0
        for (NSString *item in _fmArray) {
            BOOL isImage = [[_fmIsImage objectAtIndex:[_fmArray indexOfObject:item]] floatValue];
            [self characterHeight:item andIsImage:isImage];
        }
        // 设置view的新frame
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _fmHeight+20);
        _fmDefaultImageSize.width = self.frame.size.width;
        [self setNeedsDisplay];// 促发DrawRect事件
    }
    
    

}


// 切割字符串 并返回以图片分割后的新数组
-(void)splitString{
    // 先通过图片开始标签分割
    NSArray *tempArray = [_fmString componentsSeparatedByString:imageStartTag];
    _fmArray = [[NSMutableArray alloc] init]; // 重组数组
    _fmIsImage = [[NSMutableArray alloc] init];
    // 根据图片结束标签重组数组
    for (NSString *itemStr in tempArray) {
        NSArray *endTagArray = [itemStr componentsSeparatedByString:imageEndTag];
        int i = 0;
        for (NSString *endTagStr in endTagArray) {
            //NSLog(@"%@",endTagStr);
            [_fmArray addObject:endTagStr]; // 重新组装新数组，自此则得到了以分割完图片后的新数组，图片单独在一个下标中
            if ([itemStr rangeOfString:imageEndTag].length>0 && i==0) {
                [_fmIsImage addObject:[NSNumber numberWithBool:YES]];
            }else{
                [_fmIsImage addObject:[NSNumber numberWithBool:NO]];
            }
            i++;
        }
        endTagArray = Nil;
    }
}


-(void)characterAttribute:(NSString*)fmString andIsImage:(BOOL)isImage
{
    NSString *str = isImage?@"":fmString;
    if (_fmDefaultImageSize.width<=0){
        self.fmDefaultImageSize = CGSizeMake(self.frame.size.width,self.fmDefaultImageSize.height);
    }
    if (isImage) {
        // 创建一张图片
        UIImage *tempImage = [UIImage imageNamed:@"nophoto.png"];
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:tempImage];
        tempImageView.layer.masksToBounds = YES;
        tempImageView.layer.cornerRadius = 3;
        tempImageView.frame = CGRectMake(0, self.currentPoint.y, _fmDefaultImageSize.width, _fmDefaultImageSize.height);
        tempImageView.userInteractionEnabled = YES;
        // 把imageView加入字典
        [self.fmImages setObject:tempImageView forKey:fmString];
        // 给图片添加点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImages:)];
        [tempImageView addGestureRecognizer:tapGesture];
        [self addSubview:tempImageView];
        // 插入空行给图片预留空间
        [self insertBlankLines];
        
    }else{
        [_newString appendString:str];
    }
    if (self.isStrHeight){
        [self performSelector:@selector(stringHeight) onThread:[NSThread mainThread] withObject:Nil waitUntilDone:YES];
    }
}

// 插入几个换行，用来给图片预留空间
-(void)insertBlankLines{
    int height = _fmDefaultImageSize.height;
    int lowheight = self.lineHeight;
    int lines = height/lowheight;
    lines++;
    for(int i=1;i<=lines;i++){
        [_newString appendString:@"\r\n"];
    }
}

// 返回字符串创建的文本高度
-(void)stringHeight{
    self.currentPoint = CGPointMake(0, 0);
    if (self.isStrHeight && _newString!=NULL){
        FMTextView *tempTextView = [[FMTextView alloc] init];
        tempTextView.frame = self.frame;
        tempTextView.font = self.font;
        tempTextView.isStrHeight = NO;
        tempTextView.text = _newString;
        CGFloat tempHeight = tempTextView.frame.size.height;
        tempTextView = Nil;
        self.currentPoint = CGPointMake(0, tempHeight);
    }
    
}


-(void)openImages:(UITapGestureRecognizer*)tapGesture{
    UIImageView *tapImageView = (UIImageView*)tapGesture.view;
    NSString *imageSrc;
    for (id item in self.fmImages.keyEnumerator) {
        UIImageView *tempImageView = (UIImageView*)[self.fmImages objectForKey:item];
        if (tempImageView==tapImageView) {
            imageSrc = item;
            break;
        }
    }
    tapImageView.backgroundColor = [UIColor blackColor];
    tapImageView.alpha = 0.6;
    [UIView animateWithDuration:0.5 animations:^{
        tapImageView.backgroundColor = [UIColor whiteColor];
        tapImageView.alpha = 1;
    }];
    //NSLog(@"点击图片%@",imageSrc);
}


/*
 ----------------------------------------------------------------------------------------------------------
 以下是5.0的drawRect方式
 */

-(void)drawRect:(CGRect)rect{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]<6){
        //获取当前(View)上下文以便于之后的绘画，这个是一个离屏。
        _context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(_context , CGAffineTransformIdentity);
        
        //压栈，压入图形状态栈中.每个图形上下文维护一个图形状态栈，并不是所有的当前绘画环境的图形状态的元素都被保存。图形状态中不考虑当前路径，所以不保存
        //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
        CGContextSaveGState(_context);
        
        //x，y轴方向移动
        CGContextTranslateCTM(_context , 0 ,self.bounds.size.height);
        //缩放x，y轴方向缩放，－1.0为反向1.0倍,坐标系转换,沿x轴翻转180度
        CGContextScaleCTM(_context, 1.0 ,-1.0);
        // 开始画图
        _currentPoint = CGPointMake(0, 0);
        for (NSString *item in _fmArray) {
            BOOL isImage = [[_fmIsImage objectAtIndex:[_fmArray indexOfObject:item]] floatValue];
            // 如果是6.0以下的机子则用重绘来显示
            [self characterAttribute_5:item andIsImage:isImage];
        }
    }
    
}


// 计算高度
-(void)characterHeight:(NSString*)fmString andIsImage:(BOOL)isImage{
    NSString *str = isImage?@"":fmString;
    NSMutableAttributedString *mabstring = [self returnAttributeString:str];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mabstring);
    //计算文本绘制size
    CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(self.bounds.size.width-self.contentInset.left-self.contentInset.right, 400 * 10), NULL);
    // 更新下一坐标值
    CGFloat newY = tmpSize.height;
    if (isImage) {
        _currentPoint = CGPointMake(0, _currentPoint.y+_fmDefaultImageSize.height+newY);
    }else{
        _currentPoint = CGPointMake(0, _currentPoint.y+newY);
    }
    _fmHeight = _currentPoint.y;
    CFRelease(framesetter);
    
}
// 返回格式化后的字符串
-(NSMutableAttributedString*)returnAttributeString:(NSString*)string{
    
    NSMutableAttributedString *mabstring = [[NSMutableAttributedString alloc]initWithString:string];
    [mabstring beginEditing];
    //段落
    //line break
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //行间距
    // 设置行高
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = self.lineHeight;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);   //第二个参数为settings的长度
    [mabstring addAttribute:(NSString *)kCTParagraphStyleAttributeName
                      value:(__bridge id)paragraphStyle
                      range:NSMakeRange(0, string.length)];
    //对同一段字体进行多属性设置
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)self.textColor forKey:(id)kCTForegroundColorAttributeName];
    CTFontRef font = CTFontCreateWithName((CFStringRef)@"Heiti SC", self.font.pointSize, NULL);
    [attributes setObject:(__bridge id)font forKey:(id)kCTFontAttributeName];
    [mabstring addAttributes:attributes range:NSMakeRange(0, string.length)];
    [mabstring endEditing];
    return mabstring;
}


-(void)characterAttribute_5:(NSString*)fmString andIsImage:(BOOL)isImage{
    NSString *str = isImage?@"":fmString;
    // 如果是6.0以下的机子就用Drawrect来画
    NSMutableAttributedString *mabstring = [self returnAttributeString:str];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mabstring);
    CGMutablePathRef Path = CGPathCreateMutable();
    CGPathAddRect(Path, NULL ,CGRectMake(self.contentInset.left , -_currentPoint.y ,self.bounds.size.width-self.contentInset.left-self.contentInset.right , self.bounds.size.height));
    //计算文本绘制size
    CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(self.bounds.size.width-self.contentInset.left-self.contentInset.right, 400 * 10), NULL);
    // 更新下一坐标值
    CGFloat newY = tmpSize.height;
    if (isImage) {
        // 创建一张图片
        UIImage *tempImage = [UIImage imageNamed:@"nophoto.png"];
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:tempImage];
        tempImageView.layer.masksToBounds = YES;
        tempImageView.layer.cornerRadius = 3;
        tempImageView.frame = CGRectMake(self.contentInset.left, self.currentPoint.y, _fmDefaultImageSize.width, _fmDefaultImageSize.height);
        tempImageView.userInteractionEnabled = YES;
        //[[UIImage alloc] asyncLoad:[NSURL URLWithString:fmString] andImageView:tempImageView];
        // 把imageView加入字典
        [self.fmImages setObject:tempImageView forKey:fmString];
        // 给图片添加点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImages:)];
        [tempImageView addGestureRecognizer:tapGesture];
        [self addSubview:tempImageView];
        _currentPoint = CGPointMake(0, _currentPoint.y+_fmDefaultImageSize.height+newY);
    }else{
        _currentPoint = CGPointMake(0, _currentPoint.y+newY);
    }
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    // 画文本
    CTFrameDraw(frame,_context);
    CGPathRelease(Path);
    CFRelease(framesetter);
}


@end
