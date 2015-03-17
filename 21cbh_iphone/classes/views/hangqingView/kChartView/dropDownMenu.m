//
//  dropDownMenu.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "dropDownMenu.h"

@interface dropDownMenu()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    
}

@end

@implementation dropDownMenu

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ClearColor;
        self.btHeight = 30;
        self.time = 0.3;
        _dropState = DrowUpState; // 默认为向上收起
        self.clickIndex = -1;
        if (!_tableView) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, frame.size.height)];
            _tableView.backgroundColor = self.defaultBackgroundColor;
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:_tableView];
        }
    }
    
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.btHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.backgroundColor = ClearColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = self.font;
        UIView *view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor = self.changeBackgroundColor;
        cell.selectedBackgroundView = view;
    }
    cell.textLabel.text = [self.titles objectAtIndex:indexPath.row];
    cell.textLabel.textColor = self.color;
    if (indexPath.row==self.clickIndex) {
        cell.textLabel.textColor = self.changeColor;
        cell.backgroundColor = self.oldBackgroundColor;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = self.changeColor;
    self.clickIndex = indexPath.row;
    // 回调
    if (self.dropMenuBlock) {
        self.dropMenuBlock(self);
    }
    [self dropDown];
}

#pragma mark 画个三角形吧
-(void)drawRect:(CGRect)rect{
    // 取得画布
    //设置背景颜色
    [[UIColor clearColor] set];
    UIRectFill([self bounds]);
    
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    
    CGContextMoveToPoint(context,self.frame.size.width-20, 0);//设置起点
    
    CGContextAddLineToPoint(context,self.frame.size.width-25, 10); // 第二个点
    
    CGContextAddLineToPoint(context,self.frame.size.width-15, 10); // 第三个点
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [self.defaultBackgroundColor setFill]; //设置填充色
    
    [self.defaultBackgroundColor setStroke]; //设置边框颜色
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

#pragma mark ------------------------------自定义一些方法-------------------------------------

-(void)dropDown{
    // 通知block
    if (self.dropDownBlocks)
    {
        self.dropDownBlocks(self);
    }
    _tableView.backgroundColor = self.defaultBackgroundColor;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.btHeight*self.titles.count);
    CGFloat currentHeight = 0;
    if (_dropState == DrowUpState) {
        currentHeight = self.btHeight*self.titles.count;
    }
    [UIView animateWithDuration:self.time animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, currentHeight);
    } completion:^(BOOL isfinish){
        if (_dropState==DrowUpState) {
            _dropState = DrowDownState;
        }
        else{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
            _dropState = DrowUpState;
        }
        
        [_tableView reloadData];
    }];
}

@end
