//
//  RequestList.h
//  MultipleRequest
//
//  Created by qinghua on 14-12-26.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#define KNewQuestBaseURL @"http://test.api.21cbh.com/newapi/index.php?r="
#define KNewQuestURL(Main,Sub) [KNewQuestBaseURL stringByAppendingFormat:@"%@%@%@",Main,@"/",Sub]
#define KMainInterface @"MainInterface"
#define KSubInterface @"SubInterface"
#define KResponseError @"errno"
#define KResponseMsg @"msg"
#define KResponseApi @"api"
#define KResponseData @"data"
#define KResponseAddtime @"addtime"
#define KTimerKey @"timer"
#define KCompletionKey @"completion"

typedef enum : NSUInteger {
    ReposeStausCode_Success,
    ReposeStausCode_NetWorkError,
    ReposeStausCode_TimerOut,
} ReposeStausCode;

typedef void(^RequestRepose)(NSDictionary *dic,ReposeStausCode code);

@interface RequestManager : NSObject{
    
}
+(RequestManager *)shareRequestManager;
//-(void)addRequestWithQuest:(ASIFormDataRequest *)quest completion:(RequestRepose )block;
-(void)addRequestWithParameter:(NSDictionary *)dic completion:(RequestRepose)block;
@end
