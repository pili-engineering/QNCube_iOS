//
//  QNRoomTools.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNRoomRequest.h"

@interface QNRoomRequest ()

@property(nonatomic, copy)NSString *type;

@property(nonatomic, copy)NSString *roomId;

@end

@implementation QNRoomRequest

-(instancetype)initWithType:(NSString *)type roomId:(NSString *)roomId {
    if (self = [super init]) {
        self.type = type;
        self.roomId = roomId;
    }
    return self;
}

//房间列表
- (void)requestRoomListSuccess:(void (^)(NSArray<QNRoomInfo *> *rooms))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/listRoom" params:requestParams success:^(NSDictionary *responseData) {
            
        NSArray<QNRoomInfo *> *rooms = [QNRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        success(rooms);
        
        } failure:^(NSError *error) {
            
        }];
}

//创建房间
- (void)requestStartRoomWithName:(NSString *)name success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    QNAttrsModel *model = [QNAttrsModel new];
    model.key = @"record";
    model.value = @"true";
    [arr addObject:model];
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"title"] = name;
    requestParams[@"type"] = self.type;
    requestParams[@"params"] = [QNAttrsModel mj_keyValuesArrayWithObjectArray:arr];
    
    [QNNetworkUtil postRequestWithAction:@"base/createRoom" params:requestParams success:^(NSDictionary *responseData) {
        
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        success(model);
           
        } failure:^(NSError *error) {
        }];
}

//加入房间
- (void)requestJoinRoomWithParams:(id)params success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"type"] = self.type;
    if (self.roomId.length > 0) {
        dic[@"roomId"] = self.roomId;
    }    
    dic[@"params"] = params;
    
    [QNNetworkUtil postRequestWithAction:@"base/joinRoom" params:dic success:^(NSDictionary *responseData) {
            
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        
        model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        model.allUserList = [QNUserInfo mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];
        self.model = model;
        
        [[NSUserDefaults standardUserDefaults] setObject:model.userInfo.avatar forKey:QN_AVATAR_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        success(model);
    } failure:^(NSError *error) {
        [MBProgressHUD showText:@"加入房间失败!"];
        failure(error);
    }];
}

//获取房间信息
- (void)requestRoomInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/getRoomInfo" params:params success:^(NSDictionary *responseData) {
            
        self.model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        self.model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        self.model.allUserList = [QNUserInfo mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];

        success(self.model);
        
        } failure:^(NSError *error) {
            [MBProgressHUD showText:@"获取房间信息失败!"];
            failure(error);
        }];
}

//获取房间麦位信息
- (void)requestRoomMicInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/getRoomMicInfo" params:params success:^(NSDictionary *responseData) {
            
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        model.mics = [QNRTCMicsInfo mj_objectArrayWithKeyValuesArray:responseData[@"mics"]];
        
        success(model);
        
        } failure:^(NSError *error) {
            
            failure(error);
        }];
}

//请求上麦接口
- (void)requestUpMicSeatWithUserExtRoleType:(NSString *)userExtRoleType  clientRoleType:(QNClientRoleType)clientRoleType success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    QNUserExtension *userExtension = [QNUserExtension new];
    userExtension.userExtRoleType = self.model.userInfo.role;
    userExtension.clientRoleType = clientRoleType;
    userExtension.uid = Get_User_id;
    
    QNUserExtProfile *profile = [QNUserExtProfile new];
    profile.avatar = Get_avatar;
    profile.name = Get_Nickname;
    
    userExtension.userExtProfile = profile;
    
    params[@"userExtension"] = userExtension.mj_JSONString;
    
    [QNNetworkUtil postRequestWithAction:@"base/upMic" params:params success:^(NSDictionary *responseData) {

        success();
        
        } failure:^(NSError *error) {
            failure(error);
        }];
}

//请求下麦接口
- (void)requestDownMicSeatSuccess:(void (^)(void))success {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    params[@"uid"] = Get_User_id;
    [QNNetworkUtil postRequestWithAction:@"base/downMic" params:params success:^(NSDictionary *responseData) {
        success();
        } failure:^(NSError *error) {
        }];
}

//房间心跳
- (void)requestRoomHeartBeatWithInterval:(NSString *)interval {
    
    __weak typeof(self) weakSelf = self;
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/heartBeat" params:params success:^(NSDictionary *responseData) {
        
        NSNumber *inter = responseData[@"interval"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(inter.integerValue * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestRoomHeartBeatWithInterval:responseData[@"interval"]];
        });
        
    } failure:^(NSError *error) {
        [self requestRoomHeartBeatWithInterval:@"1"];
    }];
    
}

//请求离开房间接口
- (void)requestLeaveRoom {
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil postRequestWithAction:@"base/leaveRoom" params:params success:^(NSDictionary *responseData) {
        
        
    } failure:^(NSError *error) {
        
    }];
        
}

//获取直播记录
- (void)getLiveCodeSuccess:(void (^)(NSArray <QNLiveRecordModel *> * list))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = self.type;
    params[@"pageNum"] = @(1);
    params[@"pageSize"] = @(20);
    [QNNetworkUtil getRequestWithAction:@"record/room" params:params success:^(NSDictionary *responseData) {
            
        NSArray <QNLiveRecordModel *> *recordList = [QNLiveRecordModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        
        success(recordList);
        
        } failure:^(NSError *error) {
            
            failure(error);
        }];
    
}

@end
