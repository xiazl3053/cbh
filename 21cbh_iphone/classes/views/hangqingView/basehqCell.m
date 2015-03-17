 //
//  basehqCell.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//
#import <objc/runtime.h>
#import "basehqCell.h"
#import "changeListModel.h"
#import "DCommon.h"
#import "UIImage+ZX.h"

#define kCellViewHeight self.height-2*kCellViewTop
#define kCellBackgound UIColorFromRGB(0x333333)
#define kSmallFont [UIFont fontWithName:kFontName size:13]
#define kSmallFont10 [UIFont fontWithName:kFontName size:10]
#define kBigFont [UIFont fontWithName:kFontName size:16]
#define kBoldFont [UIFont fontWithName:kFontName size:16]

@implementation basehqCell

-(void)dealloc{
    if ([self.data class]==[NSMutableArray class]) {
        [self.data removeAllObjects];
    }
    if ([self.oldData class]==[NSMutableArray class]) {
        [self.oldData removeAllObjects];
    }
    if ([self.fileds class]==[NSMutableArray class]) {
        [self.fileds removeAllObjects];
    }
    if ([self.values class]==[NSMutableArray class]) {
        [self.values removeAllObjects];
    }
    self.data = nil;
    self.oldData = nil;
    self.fileds = nil;
    self.values = nil;
    cellView = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = kDefaultFont;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = kMarketBackground;
        self.rowCount = 5;// 初始化三列
        self.startIndex = 0;// 从第0个开始
        self.leftWidth = (self.frame.size.width)/4;
        self.cellType = 0;
//        UIView *selectView = [[UIView alloc] initWithFrame:self.frame];
//        selectView.backgroundColor = kCellBackgound;
//        self.selectedBackgroundView = selectView;
//        selectView = nil;
        cellView = [[UIView alloc] initWithFrame:self.frame];
        cellView.backgroundColor = ClearColor;
        [self addSubview:cellView];
        self.fileds = [[NSMutableArray alloc] init];
        self.values = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}

-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    if (accessoryType==UITableViewCellAccessoryDisclosureIndicator) {
        // 进入箭头图标
        UIImage *ms_in = [[UIImage imageNamed:@"ms_in.png"] scaleToSize:CGSizeMake(7, 13)];
        UIImageView *inImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-ms_in.size.width-10, (self.frame.size.height-ms_in.size.height)/2, ms_in.size.width, ms_in.size.height)];
        inImage.image = ms_in;
        [self addSubview:inImage];
        inImage = nil;
        ms_in = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setData:(NSMutableArray *)data{
    _data = data;
    if (![[_data class] isSubclassOfClass: [NSMutableArray class]]) {
        if (self.fileds) {
            [self.fileds removeAllObjects];
        }
        if (self.values) {
            [self.values removeAllObjects];
        }
        
        // 反射属性，自动赋值
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList([_data class], &outCount);
        if (self.fileds.count<=0) {
            for (int i=0; i<outCount; i++) {
                // 得到属性名称
                objc_property_t property = properties[i];
                NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
                // 得到反射的键值
                NSString *keyValue = [_data valueForKey:key];
                keyValue = keyValue==nil?@"":keyValue;
                // 装进字典
                [self.fileds addObject:key];
                [self.values addObject:keyValue];
                keyValue = nil;
                key = nil;
            }
        }
        free(properties);
        properties = nil;
    }
}

#pragma mark ---------------------------------自定义方法------------------------------------
#pragma mark 更新Cell数据
-(void)updateCell{
    if (self.data) {
        // 更新内容
        [self updateCellTitle:cellView andModle:self.data];
    }
}
#pragma mark 显示Cell
-(void)show{
    // 添加自定义视图
    [self addTitleView:cellView];
}

#pragma mark 自定义Cell内容
-(void)addTitleView:(UIView*)superView{
    CGFloat cellHeight = self.frame.size.height;
    CGFloat cellWidth = kTableViewCellRowWidth;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.leftWidth, cellHeight/3*2)];
    if (self.cellType==1) {
        title.frame = CGRectMake(60, 0, self.leftWidth-60, cellHeight);
    }
    title.font = kBigFont;
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = UIColorFromRGB(0x000000);
    title.backgroundColor = ClearColor;
    //title.text = @"1-";
    [superView addSubview:title];
    title = nil;
    
    UILabel *kid = [[UILabel alloc] initWithFrame:CGRectMake(10, cellHeight/3, self.leftWidth, cellHeight/3*2)];
    kid.font = kSmallFont10;
    kid.textAlignment = NSTextAlignmentLeft;
    kid.textColor = UIColorFromRGB(0x898989);
    kid.backgroundColor = ClearColor;
    if (self.cellType==1) {
        kid.hidden = YES;
    }
    //vol.text = @"2-";
    [superView addSubview:kid];
    kid = nil;
    CGFloat startX = self.leftWidth;
    if (self.startIndex>0) {
        startX = 0;
    }
    // 根据标题字段创建文本
    for (int i=0; i<self.rowCount-self.startIndex+1; i++) {
        UILabel *newValue = [[UILabel alloc] initWithFrame:CGRectMake(startX+cellWidth*i, 0, cellWidth, cellHeight/3*2)];
        //NSLog(@"---DFM---frame:%d,%f",i,(self.leftWidth+10)+cellWidth*i);
        newValue.font = kBoldFont;
        newValue.textAlignment = NSTextAlignmentCenter;
        newValue.textColor = [UIColor whiteColor];
        newValue.backgroundColor = ClearColor;
        //bottomLeft.text = @"3-";
        [superView addSubview:newValue];
        newValue = nil;
    }
    
}

#pragma mark 根据模型更新cell的标题内容
-(void)updateCellTitle:(UIView*)superView andModle:(id)model{
    // 写左边的名称列表
    UIColor *color = kRedColor;
    // 写右边的数值列表
    // 先判断颜色
    for (int i=self.startIndex; i<self.fileds.count; i++) {
        if (i>=self.rowCount) {
            break;
        }
        // 得到属性名称
        NSString * key = [self.fileds objectAtIndex:i];
        // 得到反射的键值
        NSString *keyValue = [model valueForKey:key];
        if ([key isEqualToString:@"changeValue"] || [key isEqualToString:@"changeRate"]) {
            // 防止值为非字符串类型
            if (![[keyValue class] isSubclassOfClass:[NSString class]]) {
                keyValue = [[NSString alloc]initWithFormat:@"%@",keyValue];
            }
            // 判断是否为负值
            if (keyValue.length>0) {
                if ([[keyValue substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]) {
                    color = kGreenColor;
                    break;
                }
            }
            
        }
        keyValue = nil;
        key = nil;
    }
    // 一些Label的颜色  总手 金额 换手 市盈 固定为黄色   总市值 流通市值 固定为白色
    NSString *yellowFiled = @"total,amount,handoff,priceEarning,";
    NSString *whiteFiled = @"totalValue,circulatedStockValue,";

    // 属性循环赋值
    for (int i=self.startIndex; i<self.fileds.count; i++) {
        if (i>=self.rowCount+1 || i>=superView.subviews.count) {
            break;
        }
        
        // 得到属性名称
        NSString * key = [self.fileds objectAtIndex:i];
        // 重新赋值lable
        UILabel *temp = (UILabel*)[superView.subviews objectAtIndex:i];
        
        // 得到反射的键值
        NSString *keyValue = [model valueForKey:key];
        if (i>1) {
            
            // 数值转换
            if ([keyValue floatValue]>10000) {
                CGFloat v = [keyValue floatValue];
                // 如果是总市值 和流通市值 转化为元
                if ([key isEqualToString:@"totalValue"] || [key isEqualToString:@"circulatedStockValue"]){
                    v = v*10000;
                }
                keyValue = [DCommon numToUnits:v];
            }else{
                if ([key isEqualToString:@"changeRate"]) {
                    keyValue = [[NSString alloc] initWithFormat:@"%0.2f%%",[keyValue floatValue]];
                }
                else{
                    keyValue = [[NSString alloc] initWithFormat:@"%0.2f",[keyValue floatValue]];
                }
            }
        }
        // 防止Null值
        if ((NSNull*)keyValue==[NSNull null] || !keyValue) {
            continue;
        }
        // 空值转换
        if ([keyValue isEqualToString:@""]) {
            keyValue = @"-";
        }
        temp.text = keyValue;
        
        if (i>1) {
            temp.textColor = color;
            // 判断并改变背景颜色
            [self compareAndChangeBgColor:temp andKey:key];
        }
        
        if ([yellowFiled rangeOfString:[NSString stringWithFormat:@"%@,",key]].length>0) {
            temp.textColor = kBrownColor;
        }
        if ([whiteFiled rangeOfString:[NSString stringWithFormat:@"%@,",key]].length>0) {
            temp.textColor = UIColorFromRGB(0x00000);
        }
        if ([key isEqualToString:@"highest"] || [key isEqualToString:@"newestValue"]) {
            if ([keyValue floatValue]<=0) {
                UILabel *firstLb = (UILabel*)[superView.subviews objectAtIndex:2];
                firstLb.text = @"-";
                firstLb = nil;
            }
            
        }
        temp = nil;
        key = nil;
        keyValue = nil;

    }
    yellowFiled = nil;
    whiteFiled = nil;
    model = nil;
}

#pragma mark 数据对比并实现闪动动画
-(void)compareAndChangeBgColor:(UILabel*)lb andKey:(NSString*)key{
    if ([key isEqualToString:@"newestValue"] || [key isEqualToString:@"changeValue"] || [key isEqualToString:@"changeRate"]) {
        if (self.oldData) {
            if (self.oldData.count>0) {
                // 得到相同Id所在的行
                int index = [self returnIdInRows];
                NSString *ov = [[self.oldData objectAtIndex:index] valueForKey:key];
                NSString *nv = [self.data valueForKey:key];
                //NSLog(@"---DFM---得到新旧数据：%@===%@，旧的第几行：%d",nv,ov,index);
                // 如果新旧数据不一则产生闪动动画
                if ([ov floatValue]!=[nv floatValue]) {
                    // 添加闪烁背景层
                    __block UIView *bg = [[UIView alloc] initWithFrame:lb.frame];
                    bg.backgroundColor = UIColorFromRGB(0x333333);
                    bg.alpha = 1.0f;
                    [self insertSubview:bg belowSubview:lb];
                    //[lb sendSubviewToBack:bg];
                    //[lb bringSubviewToFront:lb];
                    //闪烁
                    [UIView animateWithDuration:3 animations:^{
                        bg.alpha = 0.0f;
                    } completion:^(BOOL isfinish){
                        // 移除层
                        [bg removeFromSuperview];
                        bg = nil;
                    }];
                }
                nv = nil;
                ov = nil;
                lb = nil;
            }
        }
    }
    
}

#pragma mark 查找对应ID的值在第几行
-(int)returnIdInRows{
    // 得到个Id值
    NSString *_id = [self.values objectAtIndex:1];// 这里指定模型里的第2个是Id值
    // 首先得到相同Id对应的值
    for (int i=0; i<self.oldData.count; i++) {
        id model = [self.oldData objectAtIndex:i];// 得到模型
        // 反射属性，自动赋值
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList([model class], &outCount);
        // 得到属性名称
        objc_property_t property = properties[1];
        NSString * key = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        // 得到反射的键值
        NSString *keyValue = [model valueForKey:key];
        //NSLog(@"---DFM---值相同：新的值ID:%@==旧的值ID:%@",_id,keyValue);
        if (![keyValue isEqual:[NSNull null]]) {
            if ([keyValue isEqualToString:_id]) {
                return i;
            }
        }
        free(properties);
        key = nil;
        keyValue = nil;
        model = nil;
    }
    return 0;
}



@end
