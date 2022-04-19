//
//  QNMergeTrackOption.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface QNMergeTrackOption : NSObject

//在合流画面中的大小和位置
@property (nonatomic, assign) CGRect frame;

//在合流画面中的层次，0 为最底层
@property (nonatomic, assign) NSUInteger zIndex;

//图像的填充模式, 默认设置填充模式将继承 QNMergeStreamConfiguration 中数值
@property (nonatomic, assign) QNVideoFillModeType fillMode;

@end

NS_ASSUME_NONNULL_END
