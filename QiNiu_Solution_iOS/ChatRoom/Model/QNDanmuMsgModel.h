//
//  QNDanmuMsgModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
// 弹幕消息model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNDanmuMsgModel : NSObject

@property(nonatomic, strong) NSString *content;

@property(nonatomic, strong) NSString *senderName;

@property(nonatomic, strong) NSString *senderUid;

@property(nonatomic, strong) NSString *senderRoomId;

@property(nonatomic, strong) NSString *senderAvatar;

@end

NS_ASSUME_NONNULL_END
