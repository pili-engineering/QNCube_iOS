//
//  GoodsBuyListController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel;

//商品列表页面(观众)
@interface GoodsBuyListController : UIViewController

- (instancetype)initWithLiveID:(NSString *)liveID;

//点击购买商品
@property (nonatomic, copy) void (^buyClickedBlock)(GoodsModel *itemModel);

@end

NS_ASSUME_NONNULL_END
