//
//  QNAIIDCardDetect.h
//  QNAISDK
//
//  Created by 郭茜 on 2021/6/24.
//

#import <Foundation/Foundation.h>
#import "QNAIIDCardDetectParams.h"
#import "QNAIIDCardResult.h"

NS_ASSUME_NONNULL_BEGIN

// 身份证识别OCR
@interface QNAIIDCardDetect : NSObject

/// 开始进行身份证识别
/// @param params 识别请求参数
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)startDetectWithParams:(QNAIIDCardDetectParams *)params complete:(void (^)(QNAIIDCardResult *result))complete failure:(nonnull void (^)(NSError * _Nonnull error))failure;

@end

NS_ASSUME_NONNULL_END