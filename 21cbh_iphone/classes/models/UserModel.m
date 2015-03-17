//
//  UserModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "UserModel.h"
#import "FileOperation.h"

@implementation UserModel

#pragma mark 单例实例
static UserModel *_um;

#pragma mark - 单例模式
- (id)init {
    if (_um) return _um;
    
    if (self = [super init]) {
        _um = self;
    }
    return self;
}

#pragma mark 设置数据
- (void)setDict:(NSDictionary *)dict{
    if (dict) {
        self.userName=[dict objectForKey:@"userName"];
        if (!self.userName||![self.userName isKindOfClass:[NSString class]]) {
            self.userName=@"";
        }
        self.userId=[dict objectForKey:@"userId"];
        if (!self.userId||![self.userId isKindOfClass:[NSString class]]) {
            self.userId=@"";
        }
        self.nickName=[dict objectForKey:@"nickName"];
        if (!self.nickName||![self.nickName isKindOfClass:[NSString class]]) {
            self.nickName=@"";
        }
        self.balance=[dict objectForKey:@"balance"];
        if (!self.balance||![self.balance isKindOfClass:[NSString class]]) {
            self.balance=@"";
        }
        self.grade=[dict objectForKey:@"grade"];
        if (!self.grade||![self.grade isKindOfClass:[NSString class]]) {
            self.grade=@"";
        }
        self.gradeName=[dict objectForKey:@"gradeName"];
        if (!self.gradeName||![self.gradeName isKindOfClass:[NSString class]]) {
            self.gradeName=@"";
        }
        self.expbalance=[dict objectForKey:@"expbalance"];
        if (!self.expbalance||![self.expbalance isKindOfClass:[NSString class]]) {
            self.expbalance=@"";
        }
        self.picUrl=[dict objectForKey:@"picUrl"];
        if (!self.picUrl||![self.picUrl isKindOfClass:[NSString class]]) {
            self.picUrl=@"";
        }
        self.phoneNum=[dict objectForKey:@"phoneNum"];
        if (!self.phoneNum||![self.phoneNum isKindOfClass:[NSString class]]) {
            self.phoneNum=@"";
        }
        self.uuid=[dict objectForKey:@"uuid"];
        if (!self.uuid||![self.uuid isKindOfClass:[NSString class]]) {
            self.uuid=@"";
        }

    }
}


#pragma mark 清除数据
-(void)clearData{
    self.userName=nil;
    self.userId=nil;
    self.nickName=nil;
    self.balance=nil;
    self.grade=nil;
    self.gradeName=nil;
    self.expbalance=nil;
    self.picUrl=nil;
    self.phoneNum=nil;
    self.uuid=nil;
}

#pragma mark 返回单例对象
+ (UserModel *)um {
    if (_um) return _um;
    
    FileOperation *fo=[[FileOperation alloc] init];
    NSString *userDir=[fo getFileDirWithFileDirName:kUserDir];
    NSString *userFile=[userDir stringByAppendingPathComponent:kUserFile];
    _um = [NSKeyedUnarchiver unarchiveObjectWithFile:userFile];
    
    // 如果沙盒中没有账号信息
    if (!_um) {
        return [[UserModel alloc] init];
    }
    
    return _um;
}

#pragma mark 将对象写入沙盒
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userName forKey:@"userName"];
    [encoder encodeObject:_userId forKey:@"userId"];
    [encoder encodeObject:_nickName forKey:@"nickName"];
    [encoder encodeObject:_balance forKey:@"balance"];
    [encoder encodeObject:_grade forKey:@"grade"];
    [encoder encodeObject:_gradeName forKey:@"gradeName"];
    [encoder encodeObject:_expbalance forKey:@"expbalance"];
    [encoder encodeObject:_picUrl forKey:@"picUrl"];
    [encoder encodeObject:_phoneNum forKey:@"phoneNum"];
    [encoder encodeObject:_uuid forKey:@"uuid"];
}

#pragma mark 从沙盒中读取对象
- (id)initWithCoder:(NSCoder *)decoder {
    // 这里要调用self的init方法
    if (self = [self init]) {
        self.userName=[decoder decodeObjectForKey:@"userName"];
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.nickName = [decoder decodeObjectForKey:@"nickName"];
        self.balance = [decoder decodeObjectForKey:@"balance"];
        self.grade = [decoder decodeObjectForKey:@"grade"];
        self.gradeName = [decoder decodeObjectForKey:@"gradeName"];
        self.expbalance = [decoder decodeObjectForKey:@"expbalance"];
        self.picUrl = [decoder decodeObjectForKey:@"picUrl"];
        self.phoneNum = [decoder decodeObjectForKey:@"phoneNum"];
        self.uuid = [decoder decodeObjectForKey:@"uuid"];
    }
    return self;
}

@end
