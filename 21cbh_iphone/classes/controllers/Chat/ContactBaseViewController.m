//
//  ContactBaseViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-6-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ContactBaseViewController.h"
#import "Efriends.h"
#import "ChineseString.h"
#import "ChineseToPinyin.h"
#import "ChatDetailViewController.h"
#import "XMPPServer.h"


@implementation ContactBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self initViews];
    
}

-(void)initParams{
    [self initData];
}

-(void)initViews{
    
    [self initSearchBar];
    [self initTableView];
    
}



-(NSMutableArray *)zhongWenPaiXu:(NSMutableArray *)newArray//默认传入一个存名字的数组
{
    //中文排序。
    NSMutableArray *chineseStringsArray=[NSMutableArray array];//存返回的顺序数组
    
    //遍历数组中每个名字
    for(int i=0;i<[newArray count];i++)
    {
        
        ChineseString *chineseString=[[ChineseString alloc]init];//对chinesestring进行初始化（类中包括string名字和pinyin名字中所有汉字的开头大写字母）
        
        //chineseString.string=[NSString stringWithString:[newArray objectAtIndex:i]];//将名字存在string
        //替换为下面的语句:
        
        //[newArray objectAtIndex:i]得到（Student*）对象，student有个sname属性存学生的名字
        
        EFriends *desc=[newArray objectAtIndex:i];
       // chineseString.name=desc.remark;
        chineseString.name=desc.nickName;
        chineseString.jid=desc.jid;
        chineseString.userName=desc.userName;
        chineseString.nickName=desc.nickName;
        chineseString.iconUrl=desc.iconUrl;
        chineseString.isFriend=desc.isFriend;
        chineseString.isShield=desc.isShield;
        
        
        if(chineseString.name==nil)//判断名字是否为空
        {
            
            chineseString.name=@"";//如果名字是空就将string赋为0
            
        }
        
        if(![chineseString.name isEqualToString:@""])//判断名字是否为空
        {
            //名字不为空的时侯
            
            NSString *pinYinResult=[NSString string];  //存每个名字中每个字的开头大写字母
            
            // 加上以下代码同时获得学生得姓
           // chineseString.xing=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.name characterAtIndex:0])]uppercaseString];//每个名字的姓
            
            
            for(int j=0;j<chineseString.name.length;j++)//遍历名字中的每个字
            {
                
//                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.name characterAtIndex:j])]uppercaseString];//取出字中的开头字母并转为大写字母
//                
//                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];//取出名字的所有字的开头字母
            }
            
            chineseString.pinYin=pinYinResult;//将名字中所有字的开头大写字母chinesestring对象的pinYin中
        }
        else
        {
            //名字为空的时侯
            chineseString.pinYin=@"";
            
        }
        
        [chineseStringsArray addObject:chineseString];//将包含名字的大写字母和名字的chinesestring对象存在数组中
    }
    
    //按照拼音首字母对这些Strings进行排序
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];//对pinyin 进行排序  就像sql中的order by后指定的根据谁排序   生成一个数组
    
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    // 如果有需要，再把排序好的内容从ChineseString类中提取出来
    
    NSMutableArray *result=[NSMutableArray array];
    
    for(int i=0;i<[chineseStringsArray count];i++)
    {
        [result addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).name];
        
        ChineseString *desc=[chineseStringsArray objectAtIndex:i];//取出一个对象
        
        [self.xingset addObject:desc.xing];//将姓存到xingset保证不重复
        
        EFriends *item=[[EFriends alloc]init];//通过chinesestring对象的string（姓名）找到对应的学生对象
        
        item.jid=desc.jid;
        item.myJID=KUserJID;
        item.userName=desc.userName;
        item.nickName=desc.nickName;
        //item.remark=desc.name;
        item.firstChar=desc.xing;
        item.iconUrl=desc.iconUrl;
        item.isFriend=desc.isFriend;
        item.isShield=desc.isShield;
        item.pinYin=desc.pinYin;
        
       // NSLog(@"item====%@",item.userName);
        
        [self.tempA addObject:item];//将学生对象存起来
        
    }
    
    self.xingarray=(NSMutableArray*)[self.xingset allObjects];//set转为数组便于操作
   // NSLog(@"xingarray====%@",self.xingarray);
    
    
    for (int i=0; i<[self.xingarray count]; i++)//遍历所有姓
    {
        NSMutableArray *xing00=[[NSMutableArray alloc]init];
        
        for (int j=0; j<[self.tempA count]; j++)//遍历所有学生
        {
            ChineseString *tempString1=[chineseStringsArray objectAtIndex:j];//依次取出arr中的（chineseString*）对象
            
            if ([tempString1.xing isEqualToString:[self.xingarray objectAtIndex:i]]==YES) //将每个学生得姓跟每个姓比较
            {
                //姓相同就将对应的学生对象存起来
                
                [xing00 addObject:[self.tempA objectAtIndex:j]];//tempa中的对象顺序和arr中的顺序一样这里要得是学生对象所以直接从tempa中取
                //xing00存所有姓相同的学生
            }
        }
        [self.studic setObject:xing00 forKey:[self.xingarray objectAtIndex:i]];//生成对应的字典
    }
    
    //NSLog(@"self.studic=%@",self.studic);
    
    self.keyarray=(NSMutableArray*)[[self.studic allKeys]  sortedArrayUsingSelector:@selector(compare:)];//取出字典的key值并经过排序存在keyarray中
    
    return chineseStringsArray;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
