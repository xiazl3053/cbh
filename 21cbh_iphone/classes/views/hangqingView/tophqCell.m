//
//  tophqCell.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "tophqCell.h"
#import "marketIndexModel.h"
#import "popularProfessionModel.h"
#import "baseMarketListViewController.h"
#import "DCommon.h"
#import "changeListModel.h"

#define kCellViewWidth 90
#define kCellViewPadding 5
#define kCellViewTop 10
#define kCellViewHeight self.height-2*kCellViewTop
#define kCellBackgound UIColorFromRGB(0xe1e1e1)
#define kCellTitleColor UIColorFromRGB(0x000000)
#define kSmallFont [UIFont fontWithName:kFontName size:10]
#define kBigFont [UIFont fontWithName:kFontName size:14]
#define kBigBigFont [UIFont fontWithName:kFontName size:16]
#define kNumberBoldFont [UIFont fontWithName:kFontName size:16]
#define kNumberFont [UIFont fontWithName:kFontName size:10]

@implementation tophqCell

-(void)dealloc{
    one = nil;
    tow = nil;
    three = nil;
    self.data = nil;
    self.controller = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selected = NO;
        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.height = 80;
        _stateImage = [UIImage imageNamed:@"D_up.png"]; // 默认为向上的箭头
        self.backgroundColor = ClearColor;
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.origin.y, self.width-20, self.height)];
        bg.backgroundColor = kCellBackgound;
        [self addSubview:bg];
        
        bg = nil;
        // 放三个view
        [self addCellView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -------------------------------自定义方法-------------------------------
#pragma mark 添加三个子视图在cell上
-(void)addCellView{
    
    if (!one) {
        one = [[UIButton alloc] initWithFrame:CGRectMake(15, kCellViewTop, kCellViewWidth, kCellViewHeight)];
        one.backgroundColor = kCellBackgound;
        one.tag = 0;
        [one addTarget:self action:@selector(pushKlineviewController:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:one];
        [self addTitleView:one];
        
    }
    
    if (!tow) {
        tow = [[UIButton alloc] initWithFrame:CGRectMake(one.frame.origin.x+kCellViewWidth+2*kCellViewPadding,
                                                       kCellViewTop,
                                                       kCellViewWidth,
                                                       kCellViewHeight)];
        tow.backgroundColor = kCellBackgound;
        tow.tag = 1;
        [tow addTarget:self action:@selector(pushKlineviewController:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tow];
        [self addTitleView:tow];
    }
    if (!three) {
        three = [[UIButton alloc] initWithFrame:CGRectMake(tow.frame.origin.x+kCellViewWidth+2*kCellViewPadding,
                                                       kCellViewTop,
                                                       kCellViewWidth,
                                                       kCellViewHeight)];
        three.backgroundColor = kCellBackgound;
        three.tag = 2;
        [three addTarget:self action:@selector(pushKlineviewController:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:three];
        [self addTitleView:three];
    }
}
#pragma mark 给cell的子视图更新值
-(void)updateCell{
    if (self.data) {
        //NSLog(@"---DFM---更新Cell数据");
        // 开始更新每个格子内容
        for (int i=0 ;i<self.data.count;i++) {
            id model = [self.data objectAtIndex:i];// 取第一个数据
            switch (i) {
                case 0:
                    [self updateCellTitle:one andModle:model];
                    break;
                case 1:
                    [self updateCellTitle:tow andModle:model];
                    break;
                case 2:
                    [self updateCellTitle:three andModle:model];
                    break;
                default:
                    break;
            }
            
            model = nil;
        }
        
    }
    
}

#pragma mark 点击Cell推出视图
-(void)pushKlineviewController:(UIButton*)sender{
    NSInteger tag = sender.tag;
    if (self.data) {
        NSString *kId = @"";
        NSString *kName = @"";
        zhongheViewController *zh = (zhongheViewController*)self.controller;
        zh.cellDatas = self.data;
        zh = nil;
        id model = [self.data objectAtIndex:tag];// 取第一个数据
        if ([model class]==[marketIndexModel class]) {
            marketIndexModel *mModel = (marketIndexModel*)model;
            kId = mModel.marketId;
            kName = mModel.marketName;
            mModel = nil;
            // 点击大盘指数
            self.controller.kId = kId;
            self.controller.kName = kName;
            self.controller.kType = 0;
            [self.controller pushKlineController];
        }
        if ([model class]==[popularProfessionModel class]) {
            popularProfessionModel *pModel = (popularProfessionModel*)model;
            kId = pModel.professionId;
            kName = pModel.professionName;
            pModel = nil;
            // 点击热门行业
            self.controller.kId = kId;
            self.controller.kName = kName;
            self.controller.kType = 0;
            //NSLog(@"---DFM---点击了Cell里第%d个,kId=%@",tag,kId);
            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
            basemarrketList.title = @"行业板块行情";
            basemarrketList.kType = 0;
            [self.controller.market.navigationController pushViewController:basemarrketList animated:YES];
        }
        
    }
    
}

#pragma mark 格子添加内容
-(void)addTitleView:(UIView*)superView{
    CGFloat cellHeight = superView.frame.size.height;
    // 大盘指数名称
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellViewWidth, cellHeight/3+5)];
    title.font = kBigFont;
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = kCellTitleColor;
    title.backgroundColor = ClearColor;
    //title.text = @"1-";
    [superView addSubview:title];
    // 顶部加跟线吧
    UIView *line = [DCommon drawLineWithSuperView:title position:NO];
    line.backgroundColor = UIColorFromRGB(0xFFFFFF);
    line = nil;
    title = nil;
    
    // 指数
    UILabel *vol = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight/3+10, kCellViewWidth-_stateImage.size.width, cellHeight/3)];
    vol.font = kNumberBoldFont;
    vol.textAlignment = NSTextAlignmentLeft;
    vol.textColor = kCellTitleColor;
    vol.backgroundColor = ClearColor;
    //vol.text = @"2-";
    [superView addSubview:vol];
    
    // 涨跌额
    UILabel *bottomLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight/3*2+10, kCellViewWidth/2, cellHeight/3)];
    bottomLeft.font = kNumberFont;
    bottomLeft.textAlignment = NSTextAlignmentLeft;
    bottomLeft.textColor = kCellTitleColor;
    bottomLeft.backgroundColor = ClearColor;
    //bottomLeft.text = @"3-";
    [superView addSubview:bottomLeft];
    
    // 涨跌幅
    UILabel *bottomRight = [[UILabel alloc] initWithFrame:CGRectMake(kCellViewWidth/2, bottomLeft.frame.origin.y, kCellViewWidth/2, cellHeight/3)];
    bottomRight.font = kNumberFont;
    bottomRight.textAlignment = NSTextAlignmentLeft;
    bottomRight.textColor = kCellTitleColor;
    bottomRight.backgroundColor = ClearColor;
    //bottomRight.text = @"4-";
    [superView addSubview:bottomRight];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_Down@2x" ofType:@"png"];
    UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
    
    UIImageView *_stateView = [[UIImageView alloc] initWithFrame:CGRectMake(vol.frame.size.width,vol.frame.origin.y+3,
                                                                            imageSize.size.width,
                                                                            imageSize.size.height)];
    [superView addSubview:_stateView];
    _stateView = nil;
    vol = nil;
    bottomRight = nil;
    bottomLeft = nil;
}

#pragma mark 根据模型更新cell的标题内容
-(void)updateCellTitle:(UIView*)superView andModle:(id)model{
    
    _stateImage = [UIImage imageNamed:@"D_up.png"];
    
    UILabel *temp0 = (UILabel*)[superView.subviews objectAtIndex:0];
    // 线
    UIView *line0 = (UIView*)[temp0.subviews objectAtIndex:0];
    UILabel *temp1 = (UILabel*)[superView.subviews objectAtIndex:1];
    UILabel *temp2 = (UILabel*)[superView.subviews objectAtIndex:2];
    UILabel *temp3 = (UILabel*)[superView.subviews objectAtIndex:3];
    UIImageView *temp4 = (UIImageView*)[superView.subviews objectAtIndex:4];
    //NSLog(@"---DFM---更新模型%@",[model class]);
    if ([model class]==[marketIndexModel class]) {
        marketIndexModel *mModel = (marketIndexModel*)model;
        UIColor *color = kRedColor;
        if ([[mModel.changeValue substringToIndex:1] isEqualToString:@"-"]) {
            color = kGreenColor;
            _stateImage = [UIImage imageNamed:@"D_Down.png"];
        }
        temp0.text = mModel.marketName;
        temp0.textColor = color;
        line0.backgroundColor = color;
        temp1.text = mModel.totalValue;
        temp1.textColor = color;
        temp2.text = mModel.changeValue;
        temp2.textColor = color;
        NSString *changeRate = mModel.changeRate;
        if ([[changeRate substringToIndex:1] isEqualToString:@"-"]) {
            changeRate = [changeRate substringFromIndex:1];
        }
        temp3.text = [[NSString alloc] initWithFormat:@"(%@)",changeRate];
        temp3.textColor = color;
        mModel = nil;
    }
    
    if ([model class]==[popularProfessionModel class]) {
        UIColor *color = kRedColor;
        popularProfessionModel *pModel = (popularProfessionModel*)model;
        temp0.text = pModel.professionName;
        temp1.text = pModel.professionChangeRate;
        if ([[pModel.professionChangeRate substringToIndex:1] isEqualToString:@"-"]) {
            color = kGreenColor;
            _stateImage = [UIImage imageNamed:@"D_Down.png"];
        }
        temp1.textColor = color;
        temp2.text = pModel.stockName;
        temp2.textColor = kCellTitleColor;
        temp3.text = pModel.stockChangeRate;
        color = kRedColor;
        if ([[pModel.stockChangeRate substringToIndex:1] isEqualToString:@"-"]) {
            color = kGreenColor;
        }
        temp3.textColor = color;
        pModel = nil;
    }
    
    // 修正下坐标
    [temp2 sizeToFit];
    temp3.frame = CGRectMake(temp2.frame.size.width+temp2.frame.origin.x, temp2.frame.origin.y, temp2.frame.size.width, temp2.frame.size.height);
    [temp3 sizeToFit];
    temp4.image = _stateImage;
    
    temp0 = nil;
    line0 = nil;
    temp1 = nil;
    temp2 = nil;
    temp3 = nil;
    temp4 = nil;
}

@end
