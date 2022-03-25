//
//  QNBottomUserOperationView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRTCMicsInfo;

@interface QNBottomUserOperationView : UIView

//是否需要禁视频操作（纯语聊不需要禁止视频）
- (instancetype)initWithAllowVideoOperation:(BOOL)isAllow;

- (void)showWithUserInfo:(QNRTCMicsInfo *)userInfo;
//关闭音频
@property (nonatomic, copy) void (^forbiddenAudioBlock)(QNRTCMicsInfo *userInfo,BOOL forbiddenAudio);
//关闭视频
@property (nonatomic, copy) void (^forbiddenVideoBlock)(QNRTCMicsInfo *userInfo,BOOL forbiddenVideo);
//下麦
@property (nonatomic, copy) void (^kickOutMicBlock)(QNRTCMicsInfo *userInfo);

@end

NS_ASSUME_NONNULL_END
