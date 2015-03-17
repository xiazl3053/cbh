//
//  LocalContactViewController.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "LocalContactViewController.h"
#import "ContactItem.h"
#import "SessionInstance.h"
#import "UserinfoViewController.h"
#import "InviteUersrViewController.h"

@interface LocalContactViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSArray* keyArray_;
    NSArray* tempA;
    NSMutableArray* resultArray_;
    NSMutableDictionary* friendDic_;
    
    UIView* topView_;
    UITableView* tableView_;
    UISearchBar* searchBar_;
    UISearchDisplayController* searchDC_;
    
    BOOL isSearching;
}

@end

@implementation LocalContactViewController

-(void)loadView
{
    [super loadView];
    
    [self initParams];
    
    [self initViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)dealloc
{
    keyArray_=nil;
    tempA=nil;
    resultArray_=nil;
    friendDic_=nil;
}

-(void)initParams
{
    keyArray_=[NSArray array];
    tempA=[NSMutableArray array];
    resultArray_=[NSMutableArray array];
    friendDic_=[NSMutableDictionary dictionary];

    [self getAddressBook];
}

-(void)initViews
{
    topView_=[self Title:@"匹配通讯录好友" returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,topView_.frame.size.height-0.5f, topView_.frame.size.width,0.5f)];
    topLine.backgroundColor=K808080;
    [topView_ addSubview:topLine];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    searchBar_=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar_.placeholder=@"搜索";
    searchBar_.delegate=self;
    searchBar_.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    UIView *v=[searchBar_.subviews objectAtIndex:0];
    
    for (UIView *next in v.subviews) {
        if ([next isKindOfClass:NSClassFromString(@"UISearchBarBackground")])  {
            [next removeFromSuperview];
        }
    }
    
    searchDC_=[[UISearchDisplayController alloc] initWithSearchBar:searchBar_ contentsController:self];
    searchDC_.delegate=self;
    searchDC_.searchResultsDataSource=self;
    searchDC_.searchResultsDelegate=self;
    
    tableView_=[[UITableView alloc] initWithFrame:CGRectMake(0, topView_.bottom, self.view.frame.size.width, self.view.frame.size.height-topView_.frame.size.height-20) style:UITableViewStylePlain];
    tableView_.backgroundColor=ClearColor;
    tableView_.dataSource=self;
    tableView_.delegate=self;
    tableView_.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView_.tableHeaderView=searchBar_;
    tableView_.sectionIndexBackgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView_];
}

-(void)getAddressBook
{
    NSMutableSet* xingSet=[NSMutableSet set];
    tempA=INSTANCE.ContactArrays;
    for (ContactItem* item in tempA) {
        [xingSet addObject:item.xing];
    }
    
    for (NSString* xing in xingSet.allObjects) {
        NSMutableArray* tempB=[NSMutableArray array];
        for (ContactItem* item in tempA) {
            if([item.xing isEqualToString:xing])
            {
                [tempB addObject:item];
            }
        }
        [friendDic_ setObject:tempB forKey:xing];
    }
    
    keyArray_=[friendDic_.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark - ------------UITableView 的代理方法------------



-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return !isSearching?keyArray_:nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return !isSearching?keyArray_.count:1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(!isSearching)
    {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 305, 21)];
        view.backgroundColor=UIColorFromRGB(0Xe1e1e1);
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 305, 21)];
        label.font=[UIFont fontWithName:kFontName size:13];
        label.text=[keyArray_ objectAtIndex:section];
        label.textColor=UIColorFromRGB(0X000000);
        [view addSubview:label];
        
        return view;
    }
    else
    {
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!isSearching)
    {
        NSString* key=[keyArray_ objectAtIndex:section];
        NSArray* array=[friendDic_ objectForKey:key];
        return array.count;
    }
    else
    {
        return resultArray_.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LocalContactsCell";
    
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor=ClearColor;
        cell.textLabel.textColor=UIColorFromRGB(0x000000);
        
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(250, 10, 50, 20)];
        label.textColor=[UIColor whiteColor];
        label.font=[UIFont fontWithName:kFontName size:15];
        label.text=@"test";
        label.tag=201;
        [cell.contentView addSubview:label];
        
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, 320, 0.5)];
        line.backgroundColor=UIColorFromRGB(0Xe1e1e1);
        [cell.contentView addSubview:line];
    }
    
    ContactItem* item=nil;
    if(!isSearching)
    {
        NSString* key=[keyArray_ objectAtIndex:indexPath.section];
        NSArray* array=[friendDic_ objectForKey:key];
        item=[array objectAtIndex:indexPath.row];
        cell.textLabel.text=item.userName;
    }
    else
    {
        item=[resultArray_ objectAtIndex:indexPath.row];
        cell.textLabel.text=item.userName;
    }
    
    UILabel* label=(UILabel*)[cell viewWithTag:201];
    if (item.isAdded)
    {
        label.text=@"已添加";
        label.textColor=[UIColor grayColor];
    }
    else if (item.isUsed)
    {
        label.text=@"+添加";
        label.textColor=[UIColor orangeColor];
    }
    else
    {
        label.text=@"邀请";
        label.textColor=UIColorFromRGB(0x28b779);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ContactItem* item=nil;
    if(!isSearching)
    {
        NSString* key=[keyArray_ objectAtIndex:indexPath.section];
        NSArray* array=[friendDic_ objectForKey:key];
        item=[array objectAtIndex:indexPath.row];
    }
    else
    {
        item=[resultArray_ objectAtIndex:indexPath.row];
    }
    if(item.isAdded||item.isUsed)
    {
        NSString* jid=[NSString stringWithFormat:@"%@@%@",item.uuid,KXMPPDomain];
        UserinfoViewController* info=[[UserinfoViewController alloc] initWithJid:jid andType:UserInfomationOpen_TYPE_LocalContact];
        [self.navigationController pushViewController:info animated:YES];
    }
    else
    {
        InviteUersrViewController* controller=[[InviteUersrViewController alloc] initWithContact:item];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - ------------UISearchDisplayDelegate 的代理方法------------

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(searchBar_.text.length>0)
    {
        isSearching=YES;
        if(!resultArray_){
            resultArray_=[NSMutableArray array];
        }else{
            [resultArray_ removeAllObjects];
        }
        NSString* searchText=searchBar_.text;
        controller.searchResultsTableView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        controller.searchBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
        controller.searchResultsTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        for (ContactItem* item in tempA) {
            NSRange range=[item.userName rangeOfString:searchText];
            BOOL pinyin=[item.pinyin hasPrefix:searchText];
            if (pinyin||(range.length>=1)) {
                [resultArray_ addObject:item];
            }
        }
    }
    else
    {
        isSearching=NO;
    }
    return YES;
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    isSearching=NO;
}

#pragma mark - ------------UISearchBarDelegate 的代理方法------------

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=tableView_.frame;
        frame.origin=CGPointMake(0, topView_.top);
        tableView_.frame=frame;
    }];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=tableView_.frame;
        frame.origin=CGPointMake(0, topView_.bottom);
        tableView_.frame=frame;
    }];
}

@end
