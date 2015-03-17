//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

@class CellData;
@class CellView;

@protocol CellViewDelegate <NSObject>

@optional
//按钮点击完成事件
-(void)handleCellEvent:(CellView*)aSender cellData:(CellData*)aCellData;
-(void)handleCellBadgeEvent:(CellView*)aSender cellData:(CellData*)aCellData;
//刚接触按钮时,触发的事件
-(void)handleCellTouchDownEvent:(CellView*)aSender cellData:(CellData*)aCellData;

@end
