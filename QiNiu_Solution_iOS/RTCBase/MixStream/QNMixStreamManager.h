//
//  QNMixStreamManager.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMixStreamParams,QNMergeTrackOption;
//混流器
@interface QNMixStreamManager : NSObject
- (instancetype)initWithPushUrl:(NSString *)publishUrl client:(QNRTCClient *)client streamID:(NSString *)streamID;
//启动前台转推，默认实现推本地轨道
- (void)startForwardJob;
//停止前台推流
- (void)stopForwardJob;
//开始混流转推
- (void)startMixStreamJob;
//停止混流转推
- (void)stopMixStreamJob;
//设置混流参数
- (void)setMixParams:(QNMixStreamParams *)params;
//设置某个用户的音频混流参数 （isNeed 是否需要混流音频）
- (void)updateUserAudioMergeOptions:(NSString *)uid isNeed:(BOOL)isNeed;
//设置某个用户的摄像头混流参数
- (void)updateUserCameraMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;
//设置某个用户的共享屏幕混流参数
- (void)updateUserScreenMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;

@end

NS_ASSUME_NONNULL_END
