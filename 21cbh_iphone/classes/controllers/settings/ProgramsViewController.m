//
//  ProgramsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ProgramsViewController.h"
#import "GMGridView.h"
#import <QuartzCore/QuartzCore.h>
#import "FileOperation.h"
#import "MLNavigationController.h"

#define KCellHeight 43//列表那行高度
#define KItemWidth 95//Item宽度
#define KItemHeight 35//Item高度
#define KBottomMargin 30
#define Ktag1 1000
#define Ktag2 2000

@interface ProgramsViewController ()<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate>{
    GMGridView *_gmGridView1;
    GMGridView *_gmGridView2;
    UIScrollView *_scroll;
    UIView *_noSelectView;
    bool b;//动画没结束不能删除
    NSString *_key;
}

@property(strong,nonatomic)NSMutableArray *currentData;
@property(strong,nonatomic)NSMutableArray *remainData;
@property(strong,nonatomic)FileOperation *fc;

@end

@implementation ProgramsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //初始化数据
    [self initParams];
    //初始化布局
    [self initViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - --------------以下为自定义方法---------------------
#pragma mark 初始化数据
-(void)initParams{
    b=YES;
    self.currentData=[NSMutableArray array];
    self.remainData=[NSMutableArray array];
    self.fc=[[FileOperation alloc] init];
    
    if (self.nc) {
        _key=KPlistKey0;
    }
    
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"21cbh" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableArray *array=[data objectForKey:_key];
    //读取本地的plist
    self.currentData=[[self.fc getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName] objectForKey:_key];
    
    for (int i=0; i<[self.currentData count]; i++) {
        [array removeObject:self.currentData[i]];
    }
    self.remainData=array;
    for (int i=0; i<[self.remainData count]; i++) {
        NSLog(@"%@",self.remainData[i]);
    }
    
}
#pragma mark 初始布局
-(void)initViews{
    
    //标题栏
    UIView *top=[self Title:@"编辑栏目" returnType:2];
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.lable.textColor=UIColorFromRGB(0x000000);
    
    //滚动视图区
    UIScrollView *scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-top.frame.size.height)];
    scroll.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scroll];
    _scroll=scroll;
    scroll.contentSize=CGSizeMake(0, self.view.frame.size.height);
    
    //已选提示view
    UIView *selectView=[[UIView alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
    selectView.backgroundColor=UIColorFromRGB(0xffffff);
    //[scroll addSubview:selectView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 20, 70, 30)];
    label1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label1.backgroundColor=[UIColor clearColor];
    label1.text = @"已选栏目";
    label1.textAlignment = NSTextAlignmentLeft;
    label1.textColor = UIColorFromRGB(0xee5909);
    label1.font=[UIFont fontWithName:kFontName size:14];
    [selectView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x+label1.frame.size.width, 20, 150, 30)];
    label2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label2.backgroundColor=[UIColor clearColor];
    label2.text = @"点击删除 长按拖动排序";
    label2.textAlignment = NSTextAlignmentLeft;
    label2.textColor = K808080;
    label2.font=[UIFont fontWithName:kFontName size:14];
    [selectView addSubview:label2];

    //已选栏目
    NSInteger spacing = INTERFACE_IS_PHONE ? 8 : 15;
    GMGridView *gmGridView1 = [[GMGridView alloc] initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, KCellHeight*[self getRowsNum:Ktag1]+KBottomMargin)];
    gmGridView1.tag=Ktag1;
    gmGridView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView1.backgroundColor = UIColorFromRGB(0xffffff);
    _gmGridView1 = gmGridView1;
    _gmGridView1.style = GMGridViewStyleSwap;
    _gmGridView1.itemSpacing = spacing;
    _gmGridView1.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView1.centerGrid = YES;
    _gmGridView1.actionDelegate = self;
    _gmGridView1.sortingDelegate = self;
    _gmGridView1.transformDelegate = self;
    _gmGridView1.dataSource = self;
    _gmGridView1.firstCanMove=NO;
    _gmGridView1.scrollEnabled=NO;
    //不这样设置,刚进来第一点击就无移动动画(研究了很久啊)
    [_gmGridView1 scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
//-------------------------------------------------------------------------------------------------------------------------------------
    [_gmGridView1 addSubview:selectView];
    
    //未选提示view
    UIView *noSelectView=[[UIView alloc] initWithFrame:CGRectMake(0, _gmGridView1.frame.origin.y+_gmGridView1.frame.size.height+8, self.view.frame.size.width, 40)];
    [scroll addSubview:noSelectView];
    _noSelectView=noSelectView;
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 70, 30)];
    label3.backgroundColor=[UIColor clearColor];
    label3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label3.text = @"可选栏目";
    label3.textAlignment = NSTextAlignmentLeft;
    label3.textColor = UIColorFromRGB(0xee5909);
    label3.font = [UIFont systemFontOfSize:14];
    [_noSelectView addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(label3.frame.origin.x+label3.frame.size.width, 0, 150, 30)];
    label4.backgroundColor=[UIColor clearColor];
    label4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label4.text = @"点击添加";
    label4.textAlignment = NSTextAlignmentLeft;
    label4.textColor = K808080;
    label4.font = [UIFont systemFontOfSize:14];
    [_noSelectView addSubview:label4];
    
    
    //未选栏目
    GMGridView *gmGridView2 = [[GMGridView alloc] initWithFrame:CGRectMake(0, noSelectView.frame.origin.y+noSelectView.frame.size.height-20, self.view.frame.size.width, KCellHeight*[self getRowsNum:Ktag2]+KBottomMargin)];
    gmGridView2.tag=Ktag2;
    gmGridView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView2.backgroundColor = [UIColor clearColor];
    _gmGridView2 = gmGridView2;
    _gmGridView2.style = GMGridViewStyleSwap;
    _gmGridView2.itemSpacing = spacing;
    _gmGridView2.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView2.centerGrid = YES;
    _gmGridView2.actionDelegate = self;
    _gmGridView2.sortingDelegate = self;
    _gmGridView2.transformDelegate = self;
    _gmGridView2.dataSource = self;
    _gmGridView2.allCanMove=NO;
    _gmGridView2.scrollEnabled=NO;
    
    //不这样设置,刚进来第一点击就无移动动画(研究了很久啊)
    [_gmGridView2 scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
    
    [scroll addSubview:gmGridView2];
    [scroll addSubview:gmGridView1];

    
}

#pragma mark 获取行数
-(NSInteger)getRowsNum:(NSInteger)tag{
    NSMutableArray *array;
    switch (tag) {
        case 1000:
            array=_currentData;
            break;
          case 2000:
            array=_remainData;
            break;
        default:
            break;
    }
    
    int remainder=[array count]%3;
    int num=[array count]/3;
    if (remainder>0) {
        num++;
    }
    
    return num;
}

#pragma mark 重新布局scroll
-(void)changeScrollLay{
    CGRect frame=_gmGridView1.frame;
    frame.size.height=KCellHeight*[self getRowsNum:_gmGridView1.tag]+KBottomMargin;
    _gmGridView1.frame=frame;
    
    _noSelectView.frame=CGRectMake(0, _gmGridView1.frame.origin.y+_gmGridView1.frame.size.height+8, self.view.frame.size.width, 40);
    
    frame=_gmGridView2.frame;
    frame.size.height=KCellHeight*[self getRowsNum:_gmGridView2.tag]+KBottomMargin;
    frame.origin.y=_noSelectView.frame.origin.y+_noSelectView.frame.size.height-20;
    _gmGridView2.frame=frame;
    
}

#pragma mark 设置栏目页面退下
-(void)returnBack{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *data=[self.fc getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName];
        [data setObject:self.self.currentData forKey:_key];
        //plist存储到本地
        [self.fc savePlistToLocalWithNSMutableDictionary:data FileDirName:KPlistDirName fileName:KPlistName];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.nc) {
                self.nc.isFirst=YES;
                [self.nc reloadPrograma];
            }
            [super returnBack];
        });
    });

}
//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    switch (gridView.tag) {
        case Ktag1:
             return [self.currentData count];
            break;
        case Ktag2:
             return [self.remainData count];
            break;
        default:
            break;
    }
    
    return 0;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(KItemWidth, KItemHeight);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        //view.layer.cornerRadius = 8;
        view.backgroundColor=[UIColor whiteColor];
        view.layer.borderWidth=0.5;
        view.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
        view.tag=101;
        
        cell.contentView = view;
        
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = UIColorFromRGB(0x636363);
    label.font=[UIFont fontWithName:kFontName size:14];
    //label.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    UIView *view=[cell.contentView viewWithTag:101];
    switch (gridView.tag) {
        case Ktag1:
            label.text = (NSString *)[_currentData objectAtIndex:index];
            //NSLog(@"tag1:%@",[_currentData objectAtIndex:index]);
            //第一个栏目不可以移动操作,设置为灰色
            //view.backgroundColor=[UIColor clearColor];
            view.layer.borderWidth=(index==0||index==1)?0:0.5;
            view.layer.borderColor=UIColorFromRGB(0x959595).CGColor;
            break;
        case Ktag2:
            label.text = (NSString *)[_remainData objectAtIndex:index];
            //view.backgroundColor=k262626;
            //view.layer.borderWidth=0;
            break;
        default:
            break;
    }
    
    //字数多于3个时缩小字号
    //label.text.length>3?(label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12]):(label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15]);
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    switch (gridView.tag) {
        case Ktag1:
            
            // Example: removing last item
            if ([_currentData count] > 0)
            {
                if (!gridView.firstCanMove) {
                    if (position==0||position==1) {
                        return;
                    }
                }
                
                if (b) {
                    b=NO;
                    GMGridViewCell *cell =[gridView cellForItemAtIndex:position];
                    CGRect frame=cell.frame;
                    frame.origin.y+=100;
                    [UIView beginAnimations:[NSString stringWithFormat:@"%d",position] context:nil];
                    //设置动画结束的代理
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDuration:0.2];
                    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                    cell.frame=frame;
                    cell.alpha=0.0f;
                    
                    [UIView commitAnimations];
                }
                
            }
            break;
        case Ktag2:
            if ([_remainData count]>0) {
                NSObject *object=[_remainData objectAtIndex:position];
                [_gmGridView2 removeObjectAtIndex:position animated:YES];
                [_remainData removeObjectAtIndex:position];
                
                [_currentData addObject:object];
                [_gmGridView1 insertObjectAtIndex:[self.currentData count] - 1  animated:YES];
                
                [self changeScrollLay];
            }
            break;
        default:
            break;
    }

}

-(void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    NSLog(@"动画执行结束");
    NSInteger position=[animationID intValue];
    NSObject *object=[_currentData objectAtIndex:position];
    [_gmGridView1 removeObjectAtIndex:position animated:NO];
    [_currentData removeObjectAtIndex:position];
    
    [_remainData addObject:object];
    [_gmGridView2 insertObjectAtIndex:[self.remainData count] - 1  animated:YES];
   
    [self changeScrollLay];
    b=YES;
}


- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    //NSLog(@"Tap on empty space");
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //cell.contentView.backgroundColor = UIColorFromRGB(0xeeeeee);
                         //cell.contentView.layer.shadowOpacity = 0.7;
                         NSLog(@"拖拽开始");
                         _scroll.scrollEnabled=NO;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //cell.contentView.backgroundColor = [UIColor whiteColor];
                         //cell.contentView.layer.shadowOpacity = 0;
                         NSLog(@"拖拽结束");
                         _scroll.scrollEnabled=YES;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [_currentData objectAtIndex:oldIndex];
    [_currentData removeObject:object];
    [_currentData insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


//////////////////////////////////////////////////////////////
#pragma mark DraggableGridViewTransformingDelegate
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(320, 210);
        }
        else
        {
            return CGSizeMake(300, 310);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(700, 530);
        }
        else
        {
            return CGSizeMake(600, 500);
        }
    }
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %d", index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (INTERFACE_IS_PHONE)
    {
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:20];
    }
    
    [fullView addSubview:label];
    
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    NSLog(@"didStartTransformingCell");
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    NSLog(@"didEndTransformingCell");
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    NSLog(@"didEnterFullSizeForCell");
}



@end
