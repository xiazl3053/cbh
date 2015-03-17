//
//  CatarActView.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-28.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CatarActView.h"
#import "ERoomMemberModel.h"
#import "Rmbutton.h"

#define KRowMaxNumber 4
#define KItemHieght 75
#define KItemWidth 75


@interface CatarActView ()<RmbuttonDeglegate>

@end

@implementation CatarActView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithMemberArray:(NSArray *)members{

    if (self=[super init]) {
        
        NSMutableArray *sections=[NSMutableArray array];
        for (int i=0; i<members.count; i+=KRowMaxNumber) {
            if (i+KRowMaxNumber>members.count) {
                NSRange range=NSMakeRange(i, members.count-i);
                NSArray *rows=[members subarrayWithRange:range];
                [sections addObject:rows];
            }else{
                NSRange range=NSMakeRange(i, KRowMaxNumber);
                NSArray *rows=[members subarrayWithRange:range];
                [sections addObject:rows];
            }
        }
        
        self.frame=CGRectMake(0, 0, self.frame.size.width, sections.count*KItemHieght);
        for (int i=0; i<sections.count; i++) {
            NSArray *rows=[sections objectAtIndex:i];
            for (int j=0; j<rows.count;j++) {
                ERoomMemberModel *model=[rows objectAtIndex:j];
                Rmbutton* addButton=[[Rmbutton alloc]initWithFrame:CGRectMake(j*KItemWidth, i*KItemHieght, KItemWidth, KItemHieght)];
                addButton.delegate=self;
                [addButton setViewContentWithRomm:model];
                addButton.member=model;
                [self addSubview:addButton];
            }
        }
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

@end
