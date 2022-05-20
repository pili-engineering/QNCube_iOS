//
//  QNLiveRecordModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNLiveRecordModel : NSObject

@property (nonatomic, copy)NSString *userId;

@property (nonatomic, copy)NSString *roomId;

@property (nonatomic, copy)NSString *type;

@property (nonatomic, copy)NSString *timestamp;

@property (nonatomic, copy)NSString *playUrl;

@end

NS_ASSUME_NONNULL_END
