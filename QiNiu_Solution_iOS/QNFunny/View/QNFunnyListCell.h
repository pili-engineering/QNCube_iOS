//
//  QNFunnyListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel,QNRoomInfo,QNLiveRecordModel;

@interface QNFunnyListCell : UICollectionViewCell

- (void)updateWithModel:(QNRoomInfo *)model;

- (void)updateWithRecordModel:(QNLiveRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
