//
//  LogTableView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogTableView : UITableView

@property (nonatomic, assign) NSUInteger lastCount;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isBottom;

@end

NS_ASSUME_NONNULL_END
