//
//  DataInstance.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "DataInstance.h"
#import "AdBarDB.h"
#import "CommentInfoCollectDB.h"
#import "NewListCollectDB.h"
#import "NewListDB.h"
#import "NewListRecordDB.h"
#import "NewsDetailDB.h"
#import "PicInfoModelDB.h"
#import "PicDetailDB.h"
#import "PicsListCollectDB.h"
#import "PicsListDB.h"
#import "PicsListDB2.h"
#import "selfMarketDB.h"
#import "TopPicDB.h"
#import "searchStocksDB.h"
#import "PushListDB.h"

static DataInstance* instance=nil;

@implementation DataInstance

+(DataInstance *)instance
{
    @synchronized (self)
    {
        if(!instance)
        {
            instance=[[DataInstance alloc] init];
        }
        return instance;
    }
}

-(id)init
{
	if(self=[super init])
	{
		[self initDatabase];
	}
	return self;
}

-(void)initDatabase
{
    
}

-(void)closeDatabase
{
    
}

@end
