//
//  QNRTCRoom.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNRTCAbsRoom.h"
#import <QNRTCKit/QNRTCKit.h>
#import "QNRoomDetailModel.h"
#import "QNMessageCreater.h"
#import "QNRoomRequest.h"
#import "QNRTCRoomEntity.h"
#import "QNVideoTrackParams.h"
#import "QNAudioTrackParams.h"
#import "LogTableView.h"
#import "QNMixStreamManager.h"

NS_ASSUME_NONNULL_BEGIN

@class QNTrackInfo;

@interface QNRTCRoom : QNRTCAbsRoom
<
QNRTCClientDelegate,
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong)QNRoomDetailModel *model;
//IM消息创建类
@property (nonatomic, strong) QNMessageCreater *messageCreater;
//房间接口请求类
@property (nonatomic, strong) QNRoomRequest *roomRequest;
//混流器
@property (nonatomic, strong) QNMixStreamManager *mixManager;
//track传输信息展示button
@property (nonatomic, strong) UIButton *logButton;
//初始化房间
-(instancetype)initWithRoomModel:(QNRoomDetailModel *)model;
//本地视频轨道参数
- (void)setUpLocalVideoParams:(QNVideoTrackParams *)videoTrackParams;
//本地音频轨道参数
- (void)setUpLocalAudioTrackParams:(QNAudioTrackParams *)audioTrackParams;
//加入房间（有设置过房间model时直接调用此方法加入房间，不需要设置进房参数）
- (void)joinRoom;
//加入房间（需要设置进房参数）
- (void)joinRoom:(QNRTCRoomEntity *)roomEntity;
//离开房间
- (void)leaveRoom;
//启用视频模块
- (void)enableVideo;
//不启用视频模块
- (void)disableVideo;
//切换前后摄像头
- (void)switchCamera;
//开关本地摄像头推流
- (void)muteLocalVideo:(BOOL)mute;
//开关本地音频推流
- (void)muteLocalAudio:(BOOL)mute;
//屏蔽远端某用户的视频流
- (void)muteRemoteVideo:(NSString *)uid mute:(BOOL)mute;
//屏蔽远端某用户的音频流
- (void)muteRemoteAudio:(NSString *)uid mute:(BOOL)mute;
//屏蔽所有用户音频
- (void)muteAllRemoteAudio:(BOOL)mute;
//屏蔽所有用户视频
- (void)muteAllRemoteVideo:(BOOL)mute;
//设置屏幕共享参数
- (void)setScreenTrackParams:(QNVideoTrackParams *)params;
//发布本地屏幕共享
- (void)pubLocalScreenTrack;
//取消发布本地视频共享
- (void)unPubLocalScreenTrack;

//添加rtc事件监听
- (void)addExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener;
//移除rtc事件监听
- (void)removeExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener;

//设置美颜参数
- (void)setDefaultBeauty:(NSDictionary *)beautySetting;

//设置预览窗口
- (void)setlocalCameraWindowView:(UIView *)faceView;
- (void)setUserCameraWindowView:(UIView *)faceView uid:(NSString *)uid;
- (void)setUserScreenWindowView:(UIView *)faceView uid:(NSString *)uid;
- (void)setUserExtraTrackWindowView:(UIView *)faceView uid:(NSString *)uid trackTag:(NSString *)trackTag;

//获取用户视频Track
- (NSArray <QNTrack *> *)getTracksWithUser:(NSString *)userID;
- (QNTrackInfo *)getUserVideoTrackInfo:(NSString *)uid;
//获取用户音频Track
- (QNTrackInfo *)getUserAudioTrackInfo:(NSString *)uid;
//获取用户屏幕共享Track
- (QNTrackInfo *)getUserScreenTrackInfo:(NSString *)uid;
//获取自定义Track
- (QNTrackInfo *)getUserExtraTrackInfo:(NSString *)uid extraTrackTag:(NSString *)extraTrackTag;

- (void)resetRenderViews;
- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId;
- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId;
- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView;
- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView;

// 用户退出房间的时候，清除掉用户的所有信息
- (void)clearUserInfo:(NSString *)userId;

- (void)clearAllRemoteUserInfo;
//user是否是房主
- (BOOL)isAdminUser:(NSString *)userId;
//自己是否为房主
- (BOOL)isAdmin;

// 大小窗口切换
- (void)exchangeWindowSize;

- (void)leftSwipe;

- (void)rightSwipe;

@end

NS_ASSUME_NONNULL_END
