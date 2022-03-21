//
//  QNAlertViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAlertViewController : NSObject

+ (void)showBaseAlertWithTitle:(NSString *)title content:(NSString *)content handler:(void (^ __nullable)(UIAlertAction *action))handler;

+ (void)showBlackAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler;


@end

NS_ASSUME_NONNULL_END
