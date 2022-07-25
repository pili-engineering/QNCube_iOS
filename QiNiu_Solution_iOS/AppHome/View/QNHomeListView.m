//
//  QNHomeListView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/15.
//

#import "QNHomeListView.h"
#import <Masonry/Masonry.h>
#import "QNSolutionListModel.h"
#import "QNInterViewListViewController.h"
#import "QNRepairListViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "MBProgressHUD+QNShow.h"
#import "QNFunnyListController.h"
#import "QNMovieListController.h"
#import "QNVoiceChatRoomListController.h"
#import <QNLiveKit/QNLiveKit.h>

@interface QNHomeListView ()

@property (nonatomic, strong) UIImageView *itemImageView;

@property (nonatomic, strong) UILabel *itemLabel;

@end

@implementation QNHomeListView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self itemImageView];
        [self itemLabel];
    }
    return self;
}

- (void)viewForModel:(QNSolutionItemModel *)model {
    
    self.itemLabel.text = model.title;
    [self.itemImageView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    SEL itemSelector = NSSelectorFromString(model.itemSelectorNameStr);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:itemSelector];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

- (void)pkClicked {
    __weak typeof(self)weakSelf = self;
    [QLive initWithToken:QN_Live_Token serverURL:@"https://live-api.qiniu.com/%@" errorBack:^(NSError * _Nonnull error) {
        //如果token过期
        [weakSelf getLiveToken:^(NSString * _Nonnull token) {
            [QLive initWithToken:token serverURL:@"https://live-api.qiniu.com/%@" errorBack:nil];
        }];
    }];
    [QLive setUser:Get_avatar nick:Get_Nickname extension:nil];
    QLiveListController *vc = [QLiveListController new];
    [self topViewController].tabBarController.tabBar.hidden = YES;
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//获取liveToken
- (void)getLiveToken:(nullable void (^)(NSString * _Nonnull token))callBack {
    
    NSString *action = [NSString stringWithFormat:@"live/auth_token?userID=%@&deviceID=%@",Get_User_id,@"111"];
    [QNNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:responseData[@"accessToken"] forKey:Live_Token];
        [defaults synchronize];
        
        callBack(responseData[@"accessToken"]);

        } failure:^(NSError *error) {
        
        }];
}

//面试点击
- (void)interviewClicked {
    QNInterViewListViewController *vc = [QNInterViewListViewController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//检修点击
- (void)repairClicked {
    QNRepairListViewController *vc = [QNRepairListViewController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//多人连麦直播
- (void)showLiveClicked {
    
    QNFunnyListController *vc = [QNFunnyListController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
    
}

//一起看电影
- (void)movieClicked {
    QNMovieListController *vc = [QNMovieListController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//语聊房
- (void)voiceChatRoomClicked {
    QNVoiceChatRoomListController *vc = [QNVoiceChatRoomListController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}


- (void)others {
    [MBProgressHUD showText:@"敬请期待"];
}

- (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [self recursiveTopViewController:[[UIApplication sharedApplication].windows.firstObject rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (UIImageView *)itemImageView {
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc]init];
        [self addSubview:_itemImageView];
        
        [_itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(80);
            make.width.mas_equalTo(100);
        }];
    }
    return _itemImageView;
}

- (UILabel *)itemLabel {
    if (!_itemLabel) {
        _itemLabel = [[UILabel alloc]init];
        _itemLabel.font = [UIFont systemFontOfSize:14];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.textColor = [UIColor blackColor];
        [self addSubview:_itemLabel];
        
        [_itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.itemImageView);
            make.top.equalTo(self.itemImageView.mas_bottom).offset(15);
            make.width.equalTo(self.itemImageView);
            make.height.mas_equalTo(15);
        }];
    }
    return _itemLabel;
}

@end
