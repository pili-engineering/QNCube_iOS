//
//  QNBottomOperationView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//语聊房底部操作view
@interface QNVoiceChatBottomOperationView : UIView

@property (nonatomic, copy) void (^microphoneBlock)(BOOL selected);

@property (nonatomic, copy) void (^quitBlock)(void);

@property (nonatomic, copy) void (^giftBlock)(void);

@property (nonatomic, copy) void (^textBlock)(NSString *text);

@end

NS_ASSUME_NONNULL_END
