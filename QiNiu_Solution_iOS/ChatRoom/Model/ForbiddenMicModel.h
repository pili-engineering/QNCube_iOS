//
//  ForbiddenMicModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//  禁麦model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ForbiddenMicModel : NSObject

@property(nonatomic, copy) NSString *uid;

@property(nonatomic, assign) BOOL isForbidden;

@property(nonatomic, copy) NSString *msg;

@end

NS_ASSUME_NONNULL_END
