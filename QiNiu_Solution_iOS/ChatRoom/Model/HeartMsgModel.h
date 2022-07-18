//
//  HeartMsgModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//  点赞消息model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeartMsgModel : NSObject
//点赞数
@property(nonatomic, assign) NSInteger count;

@property(nonatomic, copy) NSString *senderName;

@property(nonatomic, copy) NSString *senderUid;

@property(nonatomic, copy) NSString *senderRoomId;

@end

NS_ASSUME_NONNULL_END
