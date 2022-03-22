//
//  QNAlertViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNAlertViewController.h"

@implementation QNAlertViewController

+ (void)showBaseAlertWithTitle:(NSString *)title content:(NSString *)content handler:(void (^ __nullable)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(action);
    }];
    [alertController addAction:changeBtn];
    
    [[QNAlertViewController topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (void)showTextAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^)(NSString *text))confirmHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        cancelHandler(action);
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[alertController.textFields firstObject] endEditing:YES];
        confirmHandler(alertController.textFields.firstObject.text);
    }];
    [alertController addAction:changeBtn];
    
    [[QNAlertViewController topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (void)showBlackAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithHexString:@"1B2C30"];
    }
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        cancelHandler(action);
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler(action);
    }];
    [alertController addAction:changeBtn];
    
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",title]];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, title.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];

    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:content];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, content.length)];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    alertController.view.tintColor = [UIColor whiteColor];
    [[QNAlertViewController topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [QNAlertViewController recursiveTopViewController:[[UIApplication sharedApplication].windows.firstObject rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [QNAlertViewController recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [QNAlertViewController recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [QNAlertViewController recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
