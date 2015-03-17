//
//  ChatDetailViewController.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ChatDetailViewController.h"
#import "MessageInputBar.h"
#import "ChatTableViewCell.h"
#import "UIImage+Custom.h"
#import "EMessagesDB.h"
#import "SendManager.h"
#import "ChatSettingViewController.h"
#import "NewsDetailViewController.h"
#import "QBImagePickerController.h"
#import "NewRecordListViewController.h"
#import "NewsSpecialViewController.h"
#import "UserinfoViewController.h"
#import "SelectStockViewController.h"
#import "KLineViewController.h"
#import "CommonOperation.h"
#import "ZXPhotoBrowser.h"
#import "MJPhoto.h"
#import "NewListCell.h"
#import "MJPhotoBrowser.h"
#import "XMPPServer.h"
#import "FWTPopoverView.h"
#import "WebViewController.h"
#import "SessionInstance.h"

#define NewsView 9999

@interface ChatDetailViewController ()<MessageInputBarDelegate,ChatTableViewCellDelegate,QBImagePickerControllerDelegate,NewRecordListViewControllerDelegate,ChatSettingDelegate>
{
    MessageInputBar* inputBar_;
    NSMutableArray* currentArray_;
    UITableView* mainTable_;
    
    UIView* headerView_;
    UIActivityIndicatorView* loading_;
    BOOL isLoading;
    BOOL isRoom;
    int page_;
    
    NewListModel* currentModel_;
    MessageItemAdaptor* reSendItem_;
    
    FWTPopoverView* popupView_;
}

@end

@implementation ChatDetailViewController

@synthesize currentModel=currentModel_;

-(id)initWithFriend:(EFriends*)tofriend
{
    if(self=[super init]){
        chatFriend_=tofriend;
    }
    return self;
}

-(id)initWithRoomWithJID:(NSString*)roomJID roomName:(NSString*)roomName
{
    if(self=[super init]){
        roomJID_=roomJID;
        roomName_=roomName;
        isRoom=YES;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadCacheWithAction:^(int count){
        //dispatch_sync(dispatch_get_main_queue(), ^{
            [mainTable_ reloadData];
            if(count>=15){
                [mainTable_ setTableHeaderView:headerView_];
            }
            [self scrollTableViewToBottom:NO];
        //});
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)initParams
{
    currentArray_=[NSMutableArray arrayWithCapacity:1];
    page_=0;
    [self initNotification];
}

-(void)initView
{
    NSString* name;
    if(isRoom)
        name=roomName_?roomName_:[XMPPJID jidWithString:roomJID_].user;
    else
        name=chatFriend_.nickName?chatFriend_.nickName:[XMPPJID jidWithString:chatFriend_.jid].user;

    
    UIView* topView=[self Title:name returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,topView.frame.size.height-0.5f, topView.frame.size.width,0.5f)];
    topLine.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [topView addSubview:topLine];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    UIButton* settingBtn=[[UIButton alloc] initWithFrame:CGRectMake(topView.frame.size.width-20-10,
                                                                    (topView.frame.size.height-30)/2,
                                                                    30,30)];
    [settingBtn setImage:[UIImage imageNamed:@"setting_icon.png"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:settingBtn];
    
    mainTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight+20, self.view.frame.size.width, self.view.frame.size.height-kTabHeight-kNavHeight-20) style:UITableViewStylePlain];
	mainTable_.delegate = self;
	mainTable_.dataSource = self;
    mainTable_.scrollsToTop = YES;
	mainTable_.backgroundColor = [UIColor clearColor];
    mainTable_.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:mainTable_];
    
    headerView_=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    loading_=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect rect=loading_.frame;
    rect.origin.x=(self.view.frame.size.width-loading_.frame.size.width)/2;
    rect.origin.y=5;
    loading_.frame=rect;
    loading_.color=[UIColor grayColor];
    [headerView_ addSubview:loading_];
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height-kTabHeight, kScreenWidth, kTabHeight);
    inputBar_ = [[MessageInputBar alloc] initWithFrame:frame superView:self.view];
    inputBar_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    inputBar_.delegate = self;
    [self.view addSubview:inputBar_];
    
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [mainTable_ addGestureRecognizer:tap];
    
    if(currentModel_){
        UIView* newsView=[[UIView alloc] init];
        newsView.tag=NewsView;
        NewListCell* cell=nil;
        NSInteger type=[currentModel_.type intValue];
        if (type==3) {//图集三张微缩图
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNewCell2];
            [cell setCell2:currentModel_];
            newsView.frame=CGRectMake(0, kNavHeight+20, 320, 185);
        }else{//单张微缩图
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNewCell1];
            [cell setCell1:currentModel_];
            newsView.frame=CGRectMake(0, kNavHeight+20, 320, 125);
        }
        newsView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        [newsView addSubview:cell];
        
        float y=type==3?140:80;
        
        UIButton* sendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setImage:[UIImage imageNamed:@"sendNews_icon.png"] forState:UIControlStateNormal];
        sendBtn.frame=CGRectMake(13, y, 143, 43);
        [sendBtn addTarget:self action:@selector(sendNewsModel) forControlEvents:UIControlEventTouchUpInside];
        [newsView addSubview:sendBtn];
        
        UIButton* closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"closed_icon.png"] forState:UIControlStateNormal];
        closeBtn.frame=CGRectMake(165, y, 143, 43);
        [closeBtn addTarget:self action:@selector(closedNewsModel) forControlEvents:UIControlEventTouchUpInside];
        [newsView addSubview:closeBtn];
        
        [self.view addSubview:newsView];
    }
}

-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessage:) name:kXMPPNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUpdateMessage:) name:kXMPPMsgStatusNotifaction object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPMsgStatusNotifaction object:nil];
}

-(void)tapGestureRecognizer:(UITapGestureRecognizer*)getstureRecognizer
{
    if(getstureRecognizer.state==UIGestureRecognizerStateEnded)
    {
        [self hideKeyBoardAndPopup];
    }
}

-(void)loadCacheWithAction:(void (^)(int count))action
{
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* array=[[EMessagesDB instanceWithFriendJID:[self getToJID]] selectMessageWithPage:page_];
        int count=array.count;
        [self adjustTimeInAdaptorArrays:array isTop:YES];
        if(action){
            action(count);
        }
    //});
}

#pragma 重新发送未发送成功和没超时的消息
-(void)repeatMessage:(MessageItemAdaptor*)adaptor
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendMessage:[adaptor newMessage]];
    });
}

#pragma mark 分页加载本地缓存数据
-(void)loadCacheWithPage
{
    page_++;
    [self loadCacheWithAction:^(int count){
        //dispatch_sync(dispatch_get_main_queue(), ^{
            [mainTable_ reloadData];
            [self stopLoading];
            if(count>0){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
                [mainTable_ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                CGFloat _currentY = mainTable_.contentOffset.y;
                CGFloat _currentX = mainTable_.contentOffset.x;
                _currentY += 30;
                [mainTable_ setContentOffset:CGPointMake(_currentX, _currentY)];

            }
            else{
                page_--;
            }
            if(count<15){
                mainTable_.tableHeaderView=nil;
            }
        //});
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 清空数据
-(void)cleanData
{
    INSTANCE.currentJID=nil;
    self.clearModelBlock=nil;
    [inputBar_ cleanData];
    inputBar_=nil;
    mainTable_=nil;
    [currentArray_ removeAllObjects];
    currentArray_=nil;
    [self removeNotification];
}

-(void)dealloc
{
    [self cleanData];
}

-(NSString*)getToJID
{
    NSString* toJID=isRoom?roomJID_:chatFriend_.jid;
    return toJID;
}

#pragma mark UITableView滚动到最底
-(void)scrollTableViewToBottom:(BOOL)animated
{
    if (currentArray_.count>0)
    {
        [mainTable_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentArray_.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void)hideKeyBoardAndPopup
{
    [inputBar_ hideKeyBoard];
    if(popupView_&&popupView_.isPresent)
    {
        [popupView_ dismissPopoverAnimated:YES];
    }
}

-(void)startLoading
{
    if(headerView_){
        isLoading=YES;
        headerView_.hidden=NO;
        [loading_ startAnimating];
    }
}

-(void)stopLoading
{
    if(headerView_){
        isLoading=NO;
        headerView_.hidden=YES;
        [loading_ stopAnimating];
    }
}

#pragma mark 发送新闻提醒的资讯
-(void)sendNewsModel
{
    if(currentModel_)
    {
        [self sendNews:currentModel_];
        [self closedNewsModel];
    }
}

#pragma mark 关闭新闻提醒
-(void)closedNewsModel
{
    if(self.clearModelBlock)
    {
        self.clearModelBlock();
    }
    UIView* view=[self.view viewWithTag:NewsView];
    [view removeFromSuperview];
    view=nil;
    currentModel_=nil;
}

-(void)didUpdateMessage:(NSNotification*)notifacation
{
    EMessages* msg=[notifacation.userInfo objectForKey:@"updateMsg"];
    for (int i=currentArray_.count-1; i>=0; i--) {
        MessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:i];
        if([adaptor.guId isEqualToString:msg.guid])
        {
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [mainTable_ reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

-(void)didReceiveMessage:(NSNotification *)notification
{
    EMessages* msg=[notification.userInfo objectForKey:@"newMsg"];
    if(([msg.friends_jid isEqualToString:chatFriend_.jid]&&[msg.myJID isEqualToString:KUserJID])||
       ([msg.friends_jid isEqualToString:roomJID_]&&[msg.myJID isEqualToString:KUserJID]))
    {
        MessageItemAdaptor* adaptor=[[MessageItemAdaptor alloc]initWithMessage:msg];
        [self adjustTimeInAdaptorItem:adaptor];
        [mainTable_ reloadData];
        [self scrollTableViewToBottom:YES];
    }
}

#pragma mark 当前消息是否已经存在队列中
-(BOOL)isExistInArray:(EMessages*)msg
{
    for (MessageItemAdaptor* adaptor in currentArray_) {
        if([adaptor.guId isEqualToString:msg.guid])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark 发送Message实体
-(void)sendMessage:(EMessages*)message
{
    if(message.messageType==1)
    {
        [[SendManager sharedManager] sendMessageWithImage:message];
    }
    else
    {
        [[SendManager sharedManager] sendMessageWithMessage:message roomJID:roomJID_];
    }
}
#pragma mark 发送图片消息
-(void)sendImage:(UIImage *)image isScale:(BOOL)isScale
{
    EMessages* message=[[SendManager sharedManager] imageMessageCreater:image toJID:[self getToJID] isPng:NO isScale:isScale];
    [self sendMessage:message];
}
#pragma mark 发送文本消息
-(void)sendText:(NSString*)text
{
    EMessages* message=[[SendManager sharedManager] textMessageCreater:text toJID:[self getToJID]];
    [self sendMessage:message];
}
#pragma mark 选择新闻资讯
-(void)sendNews:(NewListModel *)model
{
    EMessages* message=[[SendManager sharedManager] newsMessageCreater:model toJID:[self getToJID]];
    [self sendMessage:message];
}

#pragma mark 发送股票资讯
-(void)sendHQ:(NSString*)KId kType:(NSString*)kType kName:(NSString*)kName
{
    EMessages* message=[[SendManager sharedManager] HQMessageCreater:KId kType:kType kName:kName toJID:[self getToJID]];
    [self sendMessage:message];
}

-(void)clickSettingButton:(id)sender
{
    ChatSettingViewController* view;
    if(!isRoom)
    {
       view=[[ChatSettingViewController alloc] initWithEFriend:chatFriend_];
    }
    else
    {
        view=[[ChatSettingViewController alloc] initWithRoom:roomJID_];
    }
    view.delegate=self;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark 插入列表多个数据处理
-(void)adjustTimeInAdaptorArrays:(NSArray*)array isTop:(BOOL)isTop
{
    NSDate* last=[NSDate dateWithTimeIntervalSince1970:0];
    NSDate* frist=[NSDate dateWithTimeIntervalSince1970:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if(isTop)
    {
        if(currentArray_.count>0){
            last=((MessageItemAdaptor*)currentArray_.firstObject).timeInterval;
        }
        for (int i=array.count-1; i>=0; i--) {
            EMessages* messgae=[array objectAtIndex:i];
            MessageItemAdaptor* adaptor=[[MessageItemAdaptor alloc]initWithMessage:messgae];
            if(i==array.count-1){
                frist=adaptor.timeInterval;
            }else{
                if(abs([adaptor.timeInterval timeIntervalSinceDate:last])<=120||[adaptor.timeInterval timeIntervalSinceDate:frist]<=120){
                    adaptor.isHideTime=YES;
                }
                else{
                    last=adaptor.timeInterval;
                }
            }
            if(!adaptor.isSend&&!adaptor.isTimeOut)
            {
                [self repeatMessage:adaptor];
            }
            [currentArray_ insertObject:adaptor atIndex:array.count-i-1];
        }
    }
    else
    {
        if(currentArray_.count>0){
            last=((MessageItemAdaptor*)currentArray_.lastObject).timeInterval;
        }
        for (int i=0; i<array.count; i++) {
            EMessages* messgae=[array objectAtIndex:i];
            MessageItemAdaptor* adaptor=[[MessageItemAdaptor alloc]initWithMessage:messgae];
            if(abs([adaptor.timeInterval timeIntervalSinceDate:last])<=120){
                adaptor.isHideTime=YES;
            }
            else{
                last=adaptor.timeInterval;
            }
            if(!adaptor.isSend&&!adaptor.isTimeOut)
            {
                [self repeatMessage:adaptor];
            }
            [currentArray_ addObject:adaptor];
        }
    }
}
#pragma mark 插入列表单个数据处理
-(void)adjustTimeInAdaptorItem:(MessageItemAdaptor*)adaptor
{
    NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if(currentArray_.count>0){
        for (int i=currentArray_.count-1; i>=0; i--) {
            MessageItemAdaptor* item=[currentArray_ objectAtIndex:i];
            if(!item.isHideTime){
                last=item.timeInterval;
                break;
            }
        }
    }

    if([adaptor.timeInterval timeIntervalSinceDate:last]<=120){
        adaptor.isHideTime=YES;
    }
    [currentArray_ addObject:adaptor];
}

#pragma mark - ------------MessageInputBar 的代理方法------------
#pragma mark 键盘高度改变回调
-(void)keyboardAction:(CGFloat)height
{
    CGRect frame=mainTable_.frame;
    frame.size.height=height-kNavHeight-20;
    mainTable_.frame=frame;
    if(inputBar_.currentState!=ViewStateShowNone)
    {
        [self scrollTableViewToBottom:YES];
    }
}
#pragma mark 发送文本消息回调
-(void)sendTextAction:(NSString *)text
{
    [self sendText:text];
}
//开始录音
-(void)startRecording:(MessageInputBar *)toolbar
{
    
}
//结束录音
-(void)endRecording:(MessageInputBar *)toolbar isSend:(BOOL)isSend
{
    
}
#pragma mark 打开照相机
-(void)openCamera:(MessageInputBar *)toolbar
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
        picker.delegate = self;
        picker.allowsEditing = YES;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:^{}];//进入照相界面
    }else{
        NSLog(@"相机不可用");
    }
}
#pragma mark 发送照片
-(void)pickPhoto:(MessageInputBar *)toolbar
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.limitsMaximumNumberOfSelection = YES;
//    imagePickerController.maximumNumberOfSelection = 4;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma mark 发送股票
-(void)sendGupiao:(MessageInputBar *)toolbar
{
    SelectStockViewController* stock=[[SelectStockViewController alloc] init];
    UINavigationController* navigationController=[[UINavigationController alloc] initWithRootViewController:stock];
    [self presentViewController:navigationController animated:YES completion:nil];
    stock.userSelectStockinfo=^(NSString *markID,NSString *markType,NSString* markName)
    {
        [self sendHQ:markID kType:markType kName:markName];
    };
}

#pragma mark 选择新闻资讯回调
-(void)sendNewsAction:(MessageInputBar *)toolbar
{
    NewRecordListViewController *nrlvc=[[NewRecordListViewController alloc] init];
    nrlvc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    nrlvc.delegate=self;
    [self presentViewController:nrlvc animated:YES completion:nil];
}

#pragma mark - ------------ChatTableViewCellDelegate 的代理方法------------
#pragma mark 新闻点击回调
-(void)didClickedNews:(NSString *)programId articleId:(NSString *)articleId type:(MessageType)type
{
    self.main=[[CommonOperation getId] getMain];
    if(type==NewsMessage)
    {
        NewsDetailViewController *ndv=[[NewsDetailViewController alloc] initWithProgramId:programId articleId:articleId main:self.main isReturn:YES];
        [self.navigationController pushViewController:ndv animated:YES];
    }
    else if (type==SpecialMessage)
    {
        NewsSpecialViewController *npv=[[NewsSpecialViewController alloc] initWithProgramID:programId AndSpecialID:articleId];
        npv.main=self.main;
        [self.navigationController pushViewController:npv animated:YES];
    }
    else if (type==PicsMessage)
    {
        MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] initWithProgramId:programId picsId:articleId followNum:0 main:self.main isReturn:YES];
        [self.navigationController pushViewController:mpb animated:YES];
    }
}
#pragma mark 图片点击回调
-(void)didClickedMsgImage:(MessageItemAdaptor *)item
{
    NSMutableArray *photos = [NSMutableArray array];
    int currentIndex=0;
    int sum=0;
    BOOL isLocal=NO;
    for (int i = 0; i<currentArray_.count; i++)
    {
        MessageItemAdaptor* itemAdaptor=[currentArray_ objectAtIndex:i];
        if(itemAdaptor.msgType==ImageMessgae)
        {
            NSDictionary* picDic;
            if(itemAdaptor.isSelf)
            {
                isLocal=YES;
                picDic=[itemAdaptor.picUrls objectForKey:DSelfUpLoadImg];
            }
            else
            {
                isLocal=NO;
                picDic=[itemAdaptor.picUrls objectForKey:DLargePic];
            }
            if(picDic)
            {
                NSString* url=[picDic objectForKey:@"url"];
                MJPhoto *photo = [[MJPhoto alloc] init];
                if(isLocal){
                    photo.image=[UIImage imageWithContentsOfFile:url];//本地路径
                    if(!photo.image){
                        picDic=[itemAdaptor.picUrls objectForKey:DLargePic];
                        url=[picDic objectForKey:@"url"];
                        photo.url=[NSURL URLWithString:url];
                    }
                }else{
                    photo.url=[NSURL URLWithString:url]; //图片路径
                }
                [photos addObject:photo];
                if([itemAdaptor.guId isEqualToString:item.guId])
                {
                    currentIndex=sum;
                }
                sum++;
            }
        }
    }
    ZXPhotoBrowser *browser = [[ZXPhotoBrowser alloc] init];
    browser.currentPhotoIndex = currentIndex;
    browser.photos = photos;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark 股票点击回调
-(void)didClickedHQ:(NSString *)kId kType:(NSString *)kType// kName:(NSString*)kName
{
    KLineViewController *kline = [[KLineViewController alloc] initWithIsBack:YES KId:kId KType:[kType intValue] KName:nil];
    [self.navigationController pushViewController:kline animated:YES];
}

#pragma mark 头像点击回调
-(void)didClickedUserImage:(MessageItemAdaptor *)item
{
    if(item.fromJID)
    {
        UserinfoViewController *info=[[UserinfoViewController alloc] initWithJid:item.fromJID andType:UserInfomationOpen_TYPE_ChatDetail];
        [self.navigationController pushViewController:info animated:YES];
    }
}

#pragma mark 图片上传成功后回调
-(void)didUpLoadImgComplete:(EMessages *)msg
{
    [[SendManager sharedManager] sendUploadCompleteMessage:msg roomJID:roomJID_];
}

#pragma mark 行情信息下载成功后回调
-(void)didUpdateHQ:(EMessages *)msg
{
    [[EMessagesDB instanceWithFriendJID:[self getToJID]] updateWithMessage:msg isNotifaction:NO];
}

#pragma mark 重新发送回调
-(void)didClickedReSend:(MessageItemAdaptor *)item
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否重发消息？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag=1001;
    [alert show];
    reSendItem_=item;
}

#pragma mark 复制消息
-(void)didCopyMsg:(MessageItemAdaptor *)item
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = item.msgContent;
}

#pragma mark 删除消息
-(void)didDeleteMsg:(MessageItemAdaptor *)item
{
    [currentArray_ removeObject:item];
    if(mainTable_)
    {
        [mainTable_ reloadData];
    }
    [[EMessagesDB instanceWithFriendJID:[self getToJID]] deleteMessage:item.guId];
}

-(void)didClickNomarl:(MessageItemAdaptor *)item
{
    [self hideKeyBoardAndPopup];
}

#pragma mark cell长按回调
-(void)didLongPress:(MessageItemAdaptor *)item cellRect:(CGRect)rect showPoint:(CGPoint)point
{
    if(!popupView_)
    {
        popupView_=[[FWTPopoverView alloc] init];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 50, 30)];
        label.text=@"test";
        label.font=[UIFont systemFontOfSize:17];
        label.textColor=[UIColor redColor];
        popupView_.backgroundHelper.fillColor = [UIColor blackColor].CGColor;
        [popupView_.contentView addSubview:label];
    }
    CGRect rect1=[mainTable_ convertRect:rect toView:self.view];
    [popupView_ presentFromRect:CGRectMake(point.x,rect1.origin.y+point.y+10, 1.0f, 1.0f)
                               inView:self.view
              permittedArrowDirection:FWTPopoverArrowDirectionDown
                             animated:YES];
}

-(void)didClickedURL:(NSTextCheckingResult *)linkInfo
{
    if(linkInfo.resultType==NSTextCheckingTypeLink)
    {
        WebViewController *wv=[[WebViewController alloc] initWithUrl:linkInfo.URL.absoluteString];
        [self.navigationController pushViewController:wv animated:YES];
    }
}

#pragma mark - ------------UITableView 的代理方法------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentArray_.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:indexPath.row];
    return [ChatTableViewCell currentCellHeight:adaptor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier=@"ChatContentCell";
    ChatTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[ChatTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.delegate=self;
    }
    MessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:indexPath.row];
    [cell fillWithData:adaptor];
    
    return cell;
}

#pragma mark ----------QBImagePickerControllerDelegate 的代理方法-------------

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if([imagePickerController.class isSubclassOfClass:UIImagePickerController.class])
    {
        UIImage *chosedImage=[info objectForKey:UIImagePickerControllerEditedImage];
        [self sendImage:chosedImage isScale:YES];
    }
    else if ([imagePickerController.class isSubclassOfClass:QBImagePickerController.class])
    {
        if(imagePickerController.allowsMultipleSelection) {
            //NSArray *mediaInfoArray = (NSArray *)info;
            //[self dismissViewControllerAnimated:YES completion:^{}];
        } else {
            UIImage *chosedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
            [self sendImage:chosedImage isScale:NO];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:@"照片%d张", numberOfPhotos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"视频%d个", numberOfVideos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"照片%d张、视频%d个", numberOfPhotos, numberOfVideos];
}

#pragma mark - ------------UIScrollViewDelegate 的代理方法------------

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyBoardAndPopup];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat y=scrollView.contentOffset.y;
    if (y<=0&&!isLoading&&mainTable_.tableHeaderView!=nil) {
        [self startLoading];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadCacheWithPage) object:nil];
        [self performSelector:@selector(loadCacheWithPage) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - ------------NewRecordListViewControllerDelegate 的代理方法------------
-(void)getNewListModel:(NewListModel *)model
{
    [self sendNews:model];
}

#pragma mark - ------------ChatSettingDelegate 的代理方法------------

-(void)cleanAllMessage
{
    [currentArray_ removeAllObjects];
    [mainTable_ reloadData];
}

#pragma mark - --------------------UIAlertView的代理方法----------------------
#pragma mark 重发消息或其它提示回调
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1001)
    {
        if(buttonIndex==1)
        {
            [currentArray_ removeObject:reSendItem_];
            if(mainTable_)
            { 
                [mainTable_ reloadData];
            }
            EMessages* msg=[reSendItem_ newMessage];
            [[EMessagesDB instanceWithFriendJID:[self getToJID]] deleteMessage:msg.guid];
            [[SendManager sharedManager] messageInfo:msg toJID:[self getToJID]];
            [self sendMessage:msg];
        }
        reSendItem_=nil;
    }
}

@end
