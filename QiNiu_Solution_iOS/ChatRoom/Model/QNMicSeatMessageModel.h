//
//  QNMicSeatMessageModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/9.
//  上下麦消息model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNUserExtension,QNRTCRoomEntity;

@interface QNUserMicSeatModel : NSObject

@property (nonatomic,assign) BOOL ownerOpenAudio;

@property (nonatomic,assign) BOOL ownerOpenVideo;

@property (nonatomic, copy)NSString *uid;

@property (nonatomic,strong) QNUserExtension *userExtension;

@end

@interface QNMicSeatMessageModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNUserMicSeatModel *data;

@end

NS_ASSUME_NONNULL_END
