//
//  QNGiftView.h  礼物选择页面
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import <UIKit/UIKit.h>

@class QNGiftView,QNSendGiftModel;
@protocol JPGiftViewDelegate <NSObject>
/**
 赠送礼物

 @param giftView 礼物的选择的view
 @param model 礼物展示的数据
 */
- (void)giftViewSendGiftInView:(QNGiftView *)giftView data:(QNSendGiftModel *)model;

@end

@interface QNGiftView : UIView

/** data */
@property(nonatomic,strong) NSArray *dataArray;

- (void)showGiftView;

- (void)hiddenGiftView;

@property(nonatomic,weak)id<JPGiftViewDelegate> delegate;

@end
