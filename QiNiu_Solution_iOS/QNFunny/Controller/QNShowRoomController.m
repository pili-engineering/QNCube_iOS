//
//  QNShowRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import "QNShowRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import "QNRTCRoomEntity.h"
#import <Masonry/Masonry.h>
#import "QNAudioTrackParams.h"
#import "QNVideoTrackParams.h"
#import "QNApplyOnSeatView.h"
#import <UIKit/UIKit.h>
#import "QNChatRoomView.h"
#import "IMTextMsgModel.h"
#import <YYCategories/YYCategories.h>
#import "QNSeatNumModel.h"
#import "QNMergeTrackOption.h"

@interface QNShowRoomController ()<QNRTCClientDelegate,UITextFieldDelegate,QNIMChatServiceProtocol>

@property (nonatomic, strong) QNChatRoomView * chatRoomView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *commentTf;

@property (nonatomic, strong) NSMutableArray <QNApplyOnSeatView *> *seatViews;

@property (nonatomic, assign) BOOL onseat;

@end

@implementation QNShowRoomController

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
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.image = [UIImage imageNamed:@"showBgView"];
    [self.view addSubview:bg];
    [self.view bringSubviewToFront:self.renderBackgroundView];
    
    [self titleLabel];
    [self joinShowRoom];
    [self setupIMUI];
    [self createRemoteSeat];
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self logButton];
}

- (void)quitRoom {
        
    if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定要关闭房间？" message:@"关闭房间后，其他成员也将被踢出房间" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelBtn];
        
        UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self leave];
        }];
        [alertController addAction:changeBtn];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [self leave];
    }
        
}

- (void)leave {
    [self.roomRequest requestLeaveRoom];
    [self.roomRequest requestDownMicSeatSuccess:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)joinShowRoom {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"role"] = self.model.userInfo.role;
    [self.roomRequest requestJoinRoomWithParams:dic success:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        
        self.model = roomDetailodel;
        
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = dic[@"role"];
        self.model.userInfo = userInfo;
        
        [self joinRoomOption];
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//进房操作
- (void)joinRoomOption {
    
    [self joinRoom];
    self.rtcClient.delegate = self;
    
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.height.mas_equalTo(120);
    }];
    
    __weak typeof(self)weakSelf = self;
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
        QNIMMessageObject *message = [weakSelf.messageCreater createJoinRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [weakSelf.chatRoomView sendMessage:message];
    }];

}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    [self.chatRoomView showMessage:messages.firstObject];
}

- (void)createRemoteSeat {
    self.seatViews = [NSMutableArray array];
    CGFloat magin = (kScreenWidth - 360)/4;
    NSInteger tagIndex = 100;
    __weak typeof(self)weakSelf = self;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            QNApplyOnSeatView *seatView = [[QNApplyOnSeatView alloc]initWithFrame:CGRectMake(magin + (magin + 120) * i , 240 + j * (120 + 20), 120, 120)];
            seatView.backgroundColor = [UIColor blackColor];
            seatView.tagIndex = ++tagIndex;
            
            seatView.onSeatBlock = ^(NSInteger tag) {
                if ([weakSelf.model.userInfo.role isEqualToString:@"roomHost"] || weakSelf.onseat) {
                    return;
                }
                [weakSelf onSeatWithTag:tag];
            };
            
            seatView.alpha = 0.5;
            [weakSelf.renderBackgroundView addSubview:seatView];
            [weakSelf.seatViews addObject:seatView];
        }
    }    
}

- (void)onSeatWithTag:(NSInteger)tag {
    
    [self publishOwnTrack];
    
    self.onseat = YES;
    
    __weak typeof(self)weakSelf = self;

    [self.seatViews enumerateObjectsUsingBlock:^(QNApplyOnSeatView * _Nonnull seatView, NSUInteger idx, BOOL * _Nonnull stop) {
            
        if (seatView.tagIndex == tag) {
            seatView.isSeat = YES;
            seatView.userId = [[NSUserDefaults standardUserDefaults]objectForKey:QN_ACCOUNT_ID_KEY];
            [weakSelf.localVideoTrack play:seatView];
            
            QNIMMessageObject *message = [weakSelf.messageCreater createChatMessage:@"参与了连麦"];
            [[QNIMChatService sharedOption] sendMessage:message];
            [weakSelf.chatRoomView sendMessage:message];
            
            [weakSelf.rtcClient sendMessage:[NSString stringWithFormat:@"%ld",seatView.tagIndex] toUsers:nil messageId:nil];
        }
        
    }];
    
}


# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.chatRoomView = [[QNChatRoomView alloc] initWithFrame:CGRectMake(-10, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    [self.view addSubview:self.chatRoomView];
        
    [self setupBottomView];

}

- (void)setupBottomView {
    
    [self commentTf];
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.centerY.equalTo(self.commentTf);
        make.height.mas_equalTo(40);
    }];
    
    NSString *selectedImage[] = {@"icon_microphone_on", @"icon_video_on",@"icon_quit_show"};
    NSString *normalImage[] = {@"icon_microphone_off",@"video-close",@"icon_quit_show"};
    SEL selectors[] = {@selector(microphoneAction:),@selector(videoAction:),@selector(quitRoom)};
    CGFloat buttonWidth = 40;
    NSInteger space = (kScreenWidth - 200 - buttonWidth * 3)/4;
    
    for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:selectedImage[i]] forState:(UIControlStateSelected)];
        [button setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
        button.selected = YES;
        [bottomButtonView addSubview:button];
    }
    
    [bottomButtonView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
    [bottomButtonView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomButtonView);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}

// 打开/关闭音频
- (void)microphoneAction:(UIButton *)microphoneButton {
    microphoneButton.selected = !microphoneButton.isSelected;
    [self muteLocalAudio:!microphoneButton.isSelected];
}

// 打开/关闭视频画面
- (void)videoAction:(UIButton *)videoButton {
    videoButton.selected = !videoButton.isSelected;
    NSMutableArray *videoTracks = [[NSMutableArray alloc] init];
    if (self.localVideoTrack) {
        [videoTracks addObject:self.localVideoTrack];
        [self muteLocalVideo:!videoButton.isSelected];
    }
    [self muteLocalVideo:!videoButton.isSelected];
    // 对应实际关闭连麦视频画面的场景 可根据需求显示或隐藏摄像头采集的预览视图
    self.preview.hidden = !videoButton.isSelected;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    QNIMMessageObject *message = [self.messageCreater createChatMessage:textField.text];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    
    [self.commentTf resignFirstResponder];
    self.commentTf.text = @"";
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    [super RTCClient:client didConnectionStateChanged:state disconnectedInfo:info];
    
    if (state == QNConnectionStateConnected) {
        
        if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
            [self publishOwnTrack];
        }
        
        [self.roomRequest requestRoomHeartBeatWithInterval:@"3"];
        if ([self isAdminUser:Get_User_id]) {
            [self.mixManager startMixStreamJob];
        }        
    }
}

- (void)RTCClient:(QNRTCClient *)client didReceiveMessage:(QNMessageInfo *)message {
        
    if (message.content.length > 0) {
        
        [self.seatViews enumerateObjectsUsingBlock:^(QNApplyOnSeatView * _Nonnull seatView, NSUInteger idx, BOOL * _Nonnull stop) {
                    
        NSInteger tag =  message.content.integerValue;
            
            if (tag == idx + 101) {
                seatView.userId = message.userID;
            }
        }];
    }
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    [super RTCClient:client didUserPublishTracks:tracks ofUserID:userID];
    [self.rtcClient subscribe:tracks];
    if ([self isAdmin]) {
        [self.mixManager updateUserAudioMergeOptions:userID isNeed:YES];
        QNMergeTrackOption *option = [QNMergeTrackOption new];
        option.frame = CGRectMake(10, 300, 200, 200);
        option.zIndex = 1;
        [self.mixManager updateUserCameraMergeOptions:userID option:option];
    }
}

//远端用户视频首帧解码后的回调
- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    
    [self.rtcClient subscribe:@[videoTrack]];
        
    if ([self.roomEntity.provideHostUid isEqualToString:userID]) {
        
        QNVideoGLView *seatView = [[QNVideoGLView alloc]initWithFrame:CGRectMake(0, 0, self.preview.frame.size.width, self.preview.frame.size.height)];
        [self.preview addSubview:seatView];
        [videoTrack play:seatView];
        
    } else {
        
        for (QNApplyOnSeatView *seatView in self.seatViews) {
            if ([seatView.userId isEqualToString:userID]) {
                QNVideoGLView *vv = [[QNVideoGLView alloc]initWithFrame:CGRectMake(0, 0, seatView.frame.size.width, seatView.frame.size.height)];
                [seatView addSubview:vv];
                seatView.isSeat = YES;
                [videoTrack play:vv];
            }
        }
    }

}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
                
        //房主退出 ，通知其他成员退出
        if ([self.roomEntity.provideHostUid isEqualToString:userID]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"房主已退出" message:@"所有成员将被移出房间" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self leave];
            }];
            [alertController addAction:cancelBtn];
            
            UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self leave];
            }];
            [alertController addAction:changeBtn];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            //房间成员退出   恢复麦位
            
            for (QNApplyOnSeatView *seatView in self.seatViews) {
                if ([seatView.userId isEqualToString:userID]) {
                    
                    [seatView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[QNVideoGLView class]]) {
                            [obj removeFromSuperview];
                            seatView.isSeat = NO;
                        }
                    }];
                    
                }
            }
            
        }
    });
    
}

- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(nonnull NSArray<QNRemoteTrack *> *)tracks ofUserID:(nonnull NSString *)userID {
        
    
}

- (void)RTCClient:(QNRTCClient *)client didStartLiveStreamingWith:(NSString *)streamID {
    
}

- (void)RTCClient:(QNRTCClient *)client didErrorLiveStreamingWith:(NSString *)streamID errorInfo:(QNLiveStreamingErrorInfo *)errorInfo{
    
}

//发布自己的音视频流
- (void)publishOwnTrack {
    
    if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
        [self.localVideoTrack play:self.preview];
    }
//    self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    __weak typeof(self)weakSelf = self;
    [self.rtcClient publish:@[self.localAudioTrack,self.localVideoTrack] completeCallback:^(BOOL onPublished, NSError *error) {
        [weakSelf.roomRequest requestUpMicSeatWithUserExtRoleType:@"" clientRoleType:QNClientRoleTypeMaster success:^{} failure:^(NSError * _Nonnull error) {}];
        if ([weakSelf isAdmin]) {
            [weakSelf.mixManager updateUserAudioMergeOptions:Get_User_id isNeed:YES];
            QNMergeTrackOption *option = [QNMergeTrackOption new];
            option.frame = CGRectMake(147, 97, 120, 120);
            option.zIndex = 0;
            [self.mixManager updateUserCameraMergeOptions:Get_User_id option:option];
        }
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = self.model.roomInfo.title;
        _titleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(40);
        }];
    }
    return _titleLabel;
}

- (UITextField *)commentTf {
    if (!_commentTf) {
        _commentTf = [[UITextField alloc]initWithFrame:CGRectMake(15, kScreenHeight - 60, 200, 40)];
        _commentTf.backgroundColor = [UIColor blackColor];
        _commentTf.alpha = 0.5;
        _commentTf.delegate = self;
        _commentTf.font = [UIFont systemFontOfSize:14];
        _commentTf.layer.cornerRadius = 10;
        _commentTf.clipsToBounds = YES;
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"  说点什么..." attributes:
             @{NSForegroundColorAttributeName:[UIColor whiteColor],
               NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _commentTf.attributedPlaceholder = attrString;
        _commentTf.textColor = [UIColor whiteColor];
        [self.view addSubview:_commentTf];
    }
    return _commentTf;
}

@end
