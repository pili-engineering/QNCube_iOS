//
//  QNRoomTools.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"
#import "QNLiveRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNRoomRequest : NSObject

@property(nonatomic, strong)QNRoomDetailModel *model;

- (instancetype)initWithType:(NSString *)type roomId:(NSString *)roomId;

//获取房间列表
- (void)requestRoomListSuccess:(void (^)(NSArray<QNRoomInfo *> *rooms))success failure:(void (^)(NSError *error))failure;

//创建房间
- (void)requestStartRoomWithName:(NSString *)name success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//请求加入房间
- (void)requestJoinRoomWithParams:(id)params success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//获取房间信息
- (void)requestRoomInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//获取房间麦位信息
- (void)requestRoomMicInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//请求上麦接口
- (void)requestUpMicSeatWithUserExtRoleType:(NSString *)userExtRoleType  clientRoleType:(QNClientRoleType)clientRoleType success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//请求下麦接口
- (void)requestDownMicSeatSuccess:(void (^)(void))success;

//房间心跳
- (void)requestRoomHeartBeatWithInterval:(NSString *)interval;

//请求离开房间接口
- (void)requestLeaveRoom;

//获取直播记录
- (void)getLiveCodeSuccess:(void (^)(NSArray <QNLiveRecordModel *> * list))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
