//
//  QNForbiddenMicModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//  禁麦model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNForbiddenMsgModel : NSObject

@property(nonatomic, copy) NSString *uid;

@property(nonatomic, assign) BOOL isForbidden;

@property(nonatomic, copy) NSString *msg;

@end

@interface QNForbiddenMicModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNForbiddenMsgModel *data;

@end

NS_ASSUME_NONNULL_END
