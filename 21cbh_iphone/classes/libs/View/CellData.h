//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScrollView;

typedef enum  {
    ECellLayout_Default,
	ECellLayout_LabelBelowImage,
	ECellLayout_LabelRightImage,
	ECellLayout_LabelOnImage
} TCellLayout;

@interface CellData : NSObject 
{
	int iId;//标识，默认情况下会在添加时被设置为在scrollview中的索引位置
	
	NSString* iLabelText;//文本
    NSString* iLabelTextSelected;//文本
	UIColor* iLabelTextColor;
	UIColor* iLabelTextColorSelected;
	UIFont* labelFont_;
	CGPoint labelOriginOffset_;//文本位置偏移量
    NSTextAlignment labelTextAlignment_;
    
    UIImage* labelEmbellishImage_;//label修饰图标,在label的左边
	UIImage* labelRightEmbellishImage_;
    
	TCellLayout iCellLayout;//内部标签图片布局
	
	int iPaddingH;//cell内控件与边缘的距离
	int iPaddingV;
	
	UIImage* iImage;//在button上的图像
    NSString* imageUrl_;
    float imageCornerRadius_;
    
	UIImage* iImageHighlighted;//在button上的高亮状态的图像
	UIImage* iImageSelected;//在button上的选中状态的图像
	UIImage* iImageDisabled;//在button上的禁用状态的图像
	
	UIImage* iBgImage;//背景图片
	UIImage* iBgImageSelected;
	
	UIColor* bgColor_;//背景色
	
	BOOL iSelected;
	BOOL iKeepSelectedState;//选中后保持选中状态，再点击后恢复。此属性只影响外观，不影响点击功能。
	BOOL iScaleAspectFit;//是否缩放图片以适应

	UIViewContentMode iBgImageContentMode;
	
	NSMutableDictionary* userInfo_;//附加自定义用户数据
    
    BOOL enabled_;//是否可用
    
    UIView* badgeView_;//边角图片
    UIImage* badgeBgImage_;//角上的按钮图片
    CGPoint badgeOriginOffset_;//文本位置偏移量
}

@property (nonatomic) int iId;
@property (nonatomic,copy) NSString* iLabelText;
@property (nonatomic,copy) NSString* iLabelTextSelected;
@property (nonatomic,retain) UIColor* iLabelTextColor;
@property (nonatomic,retain) UIColor* iLabelTextColorSelected;
@property (nonatomic) NSTextAlignment labelTextAlignment;
@property (nonatomic,retain) UIFont* labelFont;
@property (nonatomic) CGPoint labelOriginOffset;
@property (nonatomic) TCellLayout cellLayout;
@property (nonatomic) int iPaddingH;
@property (nonatomic) int iPaddingV;
@property (nonatomic,retain) UIImage* iImage;
@property (nonatomic,copy) NSString* imageUrl;
@property (nonatomic,retain) UIImage* iImageSelected;
@property (nonatomic,retain) UIImage* iImageHighlighted;
@property (nonatomic,retain) UIImage* iImageDisabled;
@property (nonatomic) BOOL iSelected;
@property (nonatomic) BOOL iKeepSelectedState;
@property (nonatomic) BOOL iScaleAspectFit;
@property (nonatomic) BOOL enabled;
@property (nonatomic,retain) UIImage* iBgImage;
@property (nonatomic,retain) UIImage* iBgImageSelected;
@property (nonatomic,retain) UIColor* bgColor;
@property (nonatomic) UIViewContentMode iBgImageContentMode;
@property (nonatomic,retain) NSDictionary* userInfo;
@property (nonatomic,retain) UIView* badgeView;
@property (nonatomic,retain) UIImage* badgeBgImage;
@property (nonatomic) CGPoint badgeOriginOffset;
@property (nonatomic,retain) UIImage* labelEmbellishImage;
@property (nonatomic,retain) UIImage* labelRightEmbellishImage;
@property (nonatomic) float imageCornerRadius;

- (void)setUserInfoObject:(id)anObject forKey:(id)aKey;

@end
