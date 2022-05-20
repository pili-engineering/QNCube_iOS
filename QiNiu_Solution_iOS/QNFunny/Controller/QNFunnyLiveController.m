//
//  QNFunnyLiveController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/4/15.
//

#import "QNFunnyLiveController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNRoomDetailModel.h"
#import "QNRoomRequest.h"
#import "QNApplyOnSeatView.h"

@interface QNFunnyLiveController ()<
PLPlayerDelegate
>

@property (nonatomic, strong) PLPlayer *player;

@property (nonatomic, strong) QNRoomRequest *roomRequest;

@property (nonatomic, assign) NSInteger micNum;

@property (nonatomic, strong) NSMutableArray <QNApplyOnSeatView *> *seatViews;
@end

@implementation QNFunnyLiveController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
        
    [super viewDidLoad];
    self.title = self.model.roomInfo.title;
    self.view.backgroundColor = [UIColor whiteColor];
    [self joinShowRoom];
}

- (void)joinShowRoom {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"role"] = @"roomAudience";
    [self.roomRequest requestJoinRoomWithParams:dic success:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
            
        [self playWithUrlStr:roomDetailodel.rtcInfo.publishUrl];
        
        
        
        } failure:^(NSError * _Nonnull error) {
            
        }];
}



//获取房间正在上麦的麦位数量
- (void)getMicsNum {
    
    [self.roomRequest requestRoomMicInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
                    
        self.micNum = roomDetailodel.mics.count;
        [self updateSeatView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getMicsNum];
        });
        
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//刷新麦位
- (void)updateSeatView {

    __weak typeof(self)weakSelf = self;
    [self.seatViews enumerateObjectsUsingBlock:^(QNApplyOnSeatView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = idx < (weakSelf.micNum - 1);
    }];
    
}

- (NSMutableArray<QNApplyOnSeatView *> *)seatViews {
    if (!_seatViews) {
        _seatViews = [NSMutableArray array];
        CGFloat magin = (kScreenWidth - 360)/4;
        NSInteger tagIndex = 100;
        __weak typeof(self)weakSelf = self;
        
        for (int i = 0; i < 6; i++) {
//            for (int j = 0; j < 2; j++) {
            NSInteger line = i<3 ? 0 : 1;
            NSInteger hang = i<3 ? i : i-3;
                QNApplyOnSeatView *seatView = [[QNApplyOnSeatView alloc]initWithFrame:CGRectMake(magin + (magin + 120) * hang , 240 + line * (120 + 20), 120, 120)];
                seatView.backgroundColor = [UIColor blackColor];
                seatView.tagIndex = ++tagIndex;
                //点击座位
                seatView.onSeatBlock = ^(NSInteger tag) {
                    
                };
                
                seatView.alpha = 0.5;
                [weakSelf.player.playerView addSubview:seatView];
                [weakSelf.seatViews addObject:seatView];
//            }
        }
    }
    return _seatViews;
}

- (void)playWithUrlStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:url option:option];
    [self.view insertSubview:self.player.playerView atIndex:0];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.delegate = self;
    
    [self.player play];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 54)/2, kScreenHeight - 100 , 54, 54)];
    [button setImage:[UIImage imageNamed:@"close-phone"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    button.selected = YES;
    [self.view addSubview:button];
    
    [self getMicsNum];
}

// 退出房间
- (void)conference {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PLPlayerDelegate

//- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"Player Errro: %@", error);
//    });
//}
//
//- (void)player:(PLPlayer *)player width:(int)width height:(int)height {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"Width: %d \nHeight: %d", width, height);
//    });
//}
//
//- (void)player:(PLPlayer *)player willRenderFrame:(CVPixelBufferRef)frame pts:(int64_t)pts sarNumerator:(int)sarNumerator sarDenominator:(int)sarDenominator {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *str = [NSString stringWithFormat:@"  VideoBitrate: %.f kb/s \n  VideoFPS: %d", player.videoBitrate, player.videoFPS];
//        NSLog(@"%@", str);
//    });
//}

- (QNRoomRequest *)roomRequest {
    if (!_roomRequest) {
        _roomRequest = [[QNRoomRequest alloc]initWithType:QN_Room_Type_Show roomId:self.model.roomInfo.roomId];
    }
    return _roomRequest;
}

@end
