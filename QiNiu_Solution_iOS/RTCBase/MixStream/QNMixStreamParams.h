//
//  QNMixStreamParams.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMixStreamParams : NSObject

@property (nonatomic, assign) int mixStreamWidth;

@property (nonatomic, assign) int mixStringHeiht;

@property (nonatomic, assign) int mixStreamY;
//码率
@property (nonatomic, assign) int mixBitrate;
//帧率
@property (nonatomic, assign) int fps;
//背景参数
@property (nonatomic, strong) QNTranscodingLiveStreamingImage *backgroundInfo;

@end

NS_ASSUME_NONNULL_END
