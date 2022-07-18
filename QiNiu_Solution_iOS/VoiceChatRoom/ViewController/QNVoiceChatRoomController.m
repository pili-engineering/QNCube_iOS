//
//  QNVoiceChatRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"
#import "QNVoiceChatRoomChaterCell.h"
#import "QNQNVoiceChatRoomOnlineCell.h"
#import "QNVoiceChatRoomBottomView.h"
#import "QNVoiceChatRoomListController.h"
#import "QNAudioTrackParams.h"
#import "IMTextMsgModel.h"
#import "IMModel.h"
#import <YYCategories/YYCategories.h>
#import "QNChatRoomView.h"
#import "QNApplyOnSeatView.h"
#import "QNRoomRequest.h"
#import "QNMessageCreater.h"
#import "AlertViewController.h"
#import "QNVoiceChatRoomCell.h"
#import "InvitationModel.h"
#import "QNVoiceChatBottomOperationView.h"
#import "GiftShowManager.h"
#import "GiftView.h"
#import "SendGiftModel.h"
#import "GiftMsgModel.h"
#import "QNBottomUserOperationView.h"
#import "ForbiddenMicModel.h"
#import "MicSeatMessageModel.h"

@interface QNVoiceChatRoomController ()<QNRTCClientDelegate,QNIMChatServiceProtocol,UICollectionViewDelegate,UICollectionViewDataSource,GiftViewDelegate>

@property (nonatomic, strong) QNChatRoomView * chatRoomView;

@property(nonatomic,strong) GiftView *giftView;

@property(nonatomic,strong) QNBottomUserOperationView *userOpetationView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *masterSeat;//房主座位

@property (nonatomic, strong) NSMutableArray <QNRTCMicsInfo *> *onMicUserList;

@property (nonatomic, copy) NSString *role;

@property (nonatomic, copy) NSString *imGroupId;

@end

@implementation QNVoiceChatRoomController

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
    
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.image = [UIImage imageNamed:@"voice_chat_bg"];
    [self.view addSubview:bg];
   
    [self titleLabel];
    [self masterSeat];
    [self setupIMUI];
    [self setupBottomView];
    [self requestData];
    [self logButton];
    
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

- (void)setupBottomView {
    __weak typeof(self)weakSelf = self;
    QNVoiceChatBottomOperationView *bottomButtonView = [[QNVoiceChatBottomOperationView alloc]initWithFrame:CGRectMake(10, kScreenHeight - 60, kScreenWidth, 40)];
    bottomButtonView.microphoneBlock = ^(BOOL selected) {
        [weakSelf muteLocalAudio:!selected];
    };
    bottomButtonView.quitBlock = ^{
        [weakSelf quitRoom];
    };
    bottomButtonView.giftBlock = ^{
        [weakSelf.giftView showGiftView];
    };
    bottomButtonView.textBlock = ^(NSString * _Nonnull text) {
        QNIMMessageObject *message = [weakSelf.messageCreater createChatMessage:text];
        [[QNIMChatService sharedOption] sendMessage:message];
        [weakSelf.chatRoomView sendMessage:message];
    };
    [self.view addSubview:bottomButtonView];
}

#pragma mark  --------GiftViewDelegate---------
//点击赠送礼物的回调
- (void)giftViewSendGiftInView:(GiftView *)giftView data:(SendGiftModel *)model {
        
    model.userIcon = Get_avatar;
    model.userName = Get_Nickname;
    model.defaultCount = 0;
    model.sendCount = 1;
        
    [[GiftShowManager sharedManager] showGiftViewWithBackView:self.view info:model completeBlock:^(BOOL finished) {
        NSLog(@"赠送了礼物");
    }];
    [self sendGiftMessage:model];
}

//发送礼物信令和消息
-(void)sendGiftMessage:(SendGiftModel *)model {
    QNGiftModel *gift = [QNGiftModel new];
    gift.giftName = model.giftName;
    gift.giftId = model.giftId;
    QNIMMessageObject *message = [self.messageCreater createGiftMessage:gift number:model.sendCount extMsg:@""];
    [[QNIMChatService sharedOption] sendMessage:message];
    QNIMMessageObject *showMsg = [self.messageCreater createChatMessage:[NSString stringWithFormat:@"送出了%@个%@",@(model.sendCount),model.giftName]];
    [[QNIMChatService sharedOption] sendMessage:showMsg];
    [self.chatRoomView sendMessage:showMsg];
}

- (void)quitRoom {
    if ([Get_User_id isEqualToString:self.model.roomInfo.creator]) {
        [AlertViewController showBaseAlertWithTitle:@"确定要关闭房间？" content:@"关闭房间后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
            [self requestLeave];
        }];
    } else {
        [self requestLeave];
    }
}

//进房操作
- (void)joinRoomOption {
    [self joinRoom];
    self.rtcClient.delegate = self;
}

//加入房间
- (void)requestData {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    QNAttrsModel *model1 = [QNAttrsModel new];
    model1.key = @"role";
    model1.value = self.model.userInfo.role ?:@"roomAudience";
    self.role = model1.value;
    [arr addObject:model1];
        
    [self.roomRequest requestJoinRoomWithParams:[QNAttrsModel mj_keyValuesArrayWithObjectArray:arr] success:^(QNRoomDetailModel * roomDetailodel) {
        
        self.model = roomDetailodel;
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.role;
        self.model.userInfo = userInfo;
        
        __weak typeof(self)weakSelf = self;
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
            weakSelf.imGroupId = weakSelf.model.imConfig.imGroupId;            
            QNIMMessageObject *message = [weakSelf.messageCreater createJoinRoomMessage];
            [[QNIMChatService sharedOption] sendMessage:message];
            [weakSelf.chatRoomView sendMessage:message];
        }];
        
        [self joinRoomOption];
        
        } failure:nil];
}

//获取房间信息
- (void)getRoomInfo {
    
    [self.roomRequest requestRoomInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
            
        self.model = roomDetailodel;
        
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.role;
        self.model.userInfo = userInfo;
        
        } failure:^(NSError * _Nonnull error) {
        }];
}

//获取房间麦位信息
- (void) getRoomMicInfo {
    
    [self.roomRequest requestRoomMicInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        __weak typeof(self)weakSelf = self;
        [self dealMicArrayWithAllMics:roomDetailodel.mics callBack:^(NSMutableArray<QNRTCMicsInfo *> *arr) {
            weakSelf.onMicUserList = arr;
            [weakSelf.collectionView reloadData];
        }];
        
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//请求上麦接口
- (void)requestUpMicSeat {
    
    [self.roomRequest requestUpMicSeatWithUserExtRoleType:self.model.userInfo.role clientRoleType:1 success:^{
        
        QNIMMessageObject *message = [self.messageCreater createOnMicMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.rtcClient publish:@[self.localAudioTrack] completeCallback:^(BOOL onPublished, NSError *error) {}];
        [self getRoomMicInfo];
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//请求下麦接口
- (void)requestDownMicSeat {
    [self.roomRequest requestDownMicSeatSuccess:^{
        QNIMMessageObject *message = [self.messageCreater createDownMicMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.rtcClient unpublish:@[self.localAudioTrack]];
        [self getRoomMicInfo];
    }];
}

//离开房间
- (void)requestLeave {
    
    QNIMMessageObject *message = [self.messageCreater createLeaveRoomMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    [self.roomRequest requestDownMicSeatSuccess:^{}];
    [self.roomRequest requestLeaveRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self leaveRoom];
        
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    [super RTCClient:client didConnectionStateChanged:state disconnectedInfo:info];
    if (state == QNConnectionStateConnected) {
        
        if ([Get_User_id isEqualToString:self.model.roomInfo.creator]) {
            [self requestUpMicSeat];
        } else {
            [self getRoomMicInfo];
        }
        
        [self.roomRequest requestRoomHeartBeatWithInterval:@"3"];
    }
}

- (void)RTCClient:(QNRTCClient *)client didJoinOfUserID:(NSString *)userID userData:(NSString *)userData {
    [self getRoomInfo];
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([userID isEqualToString:self.model.roomInfo.creator]) {
            [AlertViewController showBaseAlertWithTitle:@"房间已解散" content:@"房主离开后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
                [self requestLeave];
            }];
        }
        [self getRoomMicInfo];
        [self getRoomInfo];
    });
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    [self getRoomMicInfo];
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    IMModel *messageModel = [IMModel mj_objectWithKeyValues:messages.firstObject.content];
    
    __weak typeof(self)weakSelf = self;
    if ([messageModel.action isEqualToString:@"invite_send"]) {//连麦邀请消息
        
        InvitationModel *model = [InvitationModel mj_objectWithKeyValues:messageModel.data];
        
        [AlertViewController showBlackAlertWithTitle:@"邀请提示" content:model.invitation.msg cancelHandler:^(UIAlertAction * _Nonnull action) {
             QNIMMessageObject *message = [weakSelf.messageCreater createRejectInviteMessageWithInvitationName:@"audioroomupmic" receiverId:model.invitation.initiatorUid];
            [[QNIMChatService sharedOption] sendMessage:message];
            
            [weakSelf getRoomMicInfo];
            
        } confirmHandler:^(UIAlertAction * _Nonnull action) {
                    
            QNIMMessageObject *message = [weakSelf.messageCreater createAcceptInviteMessageWithInvitationName:@"audioroomupmic" receiverId:model.invitation.initiatorUid];
           [[QNIMChatService sharedOption] sendMessage:message];
            [weakSelf getRoomMicInfo];
        }];
        
    } else if ([messageModel.action isEqualToString:@"living_gift"]) {//收到礼物消息
        
        GiftMsgModel *model = [GiftMsgModel mj_objectWithKeyValues:messageModel.data];
        [self receivedGift:model];
        
    }  else if ([messageModel.action isEqualToString:@"invite_reject"]) {//连麦被拒绝消息
        
        [MBProgressHUD showText:@"对方拒绝了你的连麦申请"];
        
    } else if ([messageModel.action isEqualToString:@"invite_accept"]) {//连麦被接受消息
        
        [self requestUpMicSeat];
        QNIMMessageObject *message = [self.messageCreater createChatMessage:@"参与了连麦"];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.chatRoomView sendMessage:message];
        
    } else if ([messageModel.action isEqualToString:@"rtc_sitDown"]) {//用户上麦信息
        
        [self getRoomMicInfo];
        
    } else if ([messageModel.action isEqualToString:@"rtc_sitUp"]) {//用户下麦信息
        
        [self getRoomMicInfo];
        
    } else if ([messageModel.action isEqualToString:@"welcome"]){ //进房消息
        [self.chatRoomView showMessage:messages.firstObject];
        [self getRoomInfo];
        [self getRoomMicInfo];
    } else if ([messageModel.action isEqualToString:@"quit_room"]) {//离开消息
        
        [self.chatRoomView showMessage:messages.firstObject];
        [self getRoomInfo];
        [self getRoomMicInfo];
       
    } else if ([messageModel.action isEqualToString:@"pub_chat_text"]) {//聊天消息
        
        [self.chatRoomView showMessage:messages.firstObject];
        
    } else if ([messageModel.action isEqualToString:@"rtc_forbiddenAudio"]) {//禁麦消息
        
        ForbiddenMicModel *model = [ForbiddenMicModel mj_objectWithKeyValues:messageModel.data];
        if ([model.uid isEqualToString:Get_User_id]) {
            [self.localAudioTrack updateMute:model.isForbidden];
            if (model.isForbidden) {
                [MBProgressHUD showText:@"您已被房主禁麦"];
            } else {
                [MBProgressHUD showText:@"您已被房主开麦，可以开始说话了"];
            }
        }
    } else if ([messageModel.action isEqualToString:@"rtc_kickOutFromMicSeat"]) {//踢麦消息
        
        QNIMSeatOperationModel *model = [QNIMSeatOperationModel mj_objectWithKeyValues:messageModel.data];
        if ([model.seat.uid isEqualToString:Get_User_id]) {
            [MBProgressHUD showText:@"您已被房主下麦"];
            [self requestDownMicSeat];
        }
    }
}

//收到礼物信令的操作
- (void)receivedGift:(GiftMsgModel *)model {
    SendGiftModel *sendModel = [SendGiftModel new];
    sendModel.userIcon = model.senderAvatar;
    sendModel.userName = model.senderName;
    sendModel.defaultCount = 0;
    sendModel.sendCount = model.number;
    sendModel.giftName = model.sendGift.giftName;
    //通过礼物名字找到本地的礼物图
    for (SendGiftModel *gift in self.giftView.dataArray) {
        if ([model.sendGift.giftName isEqualToString:gift.giftName]) {
            sendModel.giftImage = gift.giftImage;
            sendModel.giftGifImage = gift.giftGifImage;
        }
    }
    [[GiftShowManager sharedManager] showGiftViewWithBackView:self.view info:sendModel completeBlock:^(BOOL finished) {
    }];
}

- (void)leaveToRoomList {
    
    UIViewController * presentingViewController = self.presentingViewController;
    do {
        if ([presentingViewController isKindOfClass:[QNVoiceChatRoomListController class]]) {
            break;
        }
        presentingViewController = presentingViewController.presentingViewController;
        
    } while (presentingViewController.presentingViewController);

    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self requestLeave];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNVoiceChatRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNVoiceChatRoomCell" forIndexPath:indexPath];
    [cell updateWithModel:self.onMicUserList[indexPath.item]];
    __weak typeof(self)weakSelf = self;
    cell.onSeatBlock = ^{
        
        if ([weakSelf isAdminUser:Get_User_id]) {
            [weakSelf.userOpetationView showWithUserInfo:self.onMicUserList[indexPath.item]];
            return;
        }
        
        [weakSelf sendInvitationUpMic];
    };
    return cell;
}

//请求上麦
- (void)sendInvitationUpMic {
    
    if ([self isOnMic]) {
        [MBProgressHUD showText:@"您已经在麦上"];
        [self getRoomMicInfo];
        return;
    }
    
    QNIMMessageObject *message = [self.messageCreater createInviteMessageWithInvitationName:@"audioroomupmic" receiverId:self.model.roomInfo.creator];
    [[QNIMChatService sharedOption] sendMessage:message];
    
    QNIMMessageObject *applyMessage = [self.messageCreater createChatMessage:@"申请连麦，等待房主同意..."];
    [[QNIMChatService sharedOption] sendMessage:applyMessage];
    [self.chatRoomView sendMessage:applyMessage];
}

//判断是否已经在麦上
- (BOOL)isOnMic {
    if ([Get_User_id isEqualToString:self.model.roomInfo.creator]) {
        return YES;
    }
    for (QNRTCMicsInfo  *mic in self.onMicUserList) {
        if ([Get_User_id isEqualToString:mic.uid]) {
            return YES;
        }
    }
    return NO;
}
//处理麦位数组(将房主的麦位从数组中剔除)
- (void)dealMicArrayWithAllMics:(NSArray <QNRTCMicsInfo *> *)allMics callBack:(void (^)(NSMutableArray <QNRTCMicsInfo *> *arr))callBack{
        
    [self.onMicUserList removeAllObjects];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:allMics];
    //房主不显示在连麦位置上
    for (QNRTCMicsInfo *mic in allMics) {
        if ([mic.uid isEqualToString:self.model.roomInfo.creator]) {
            
            NSData *JSONData = [mic.userExtension dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

            QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
            [self.masterSeat sd_setImageWithURL:[NSURL URLWithString:user.userExtProfile.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
            
            [arr removeObject:mic];
        }
    }
    //空位置index补充
    for (int i = 0; i < 6; i++) {
        QNRTCMicsInfo * mic = [QNRTCMicsInfo new];
        
        QNUserExtension *user = [QNUserExtension new];
        user.uid = @"uid";
        QNUserExtProfile *profile = [QNUserExtProfile new];
        profile.name = @"name";
//        profile.avatar = @"avatar";
        user.userExtProfile = profile;
        
        mic.userExtension = user.mj_JSONString;
        
        if (arr.count < 6) {
            [arr addObject:mic];
        }
    }
    callBack(arr);
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

- (UIImageView *)masterSeat{
    if (!_masterSeat) {
        _masterSeat = [[UIImageView alloc]initWithFrame:CGRectMake(20, 80, 120, 120)];
        _masterSeat.layer.cornerRadius = 10;
        _masterSeat.clipsToBounds = YES;
        [self.view addSubview:_masterSeat];
    }
    return _masterSeat;
}

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    self.chatRoomView = [[QNChatRoomView alloc] initWithFrame:CGRectMake(-10, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    [self.view addSubview:self.chatRoomView];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 80)/3, (kScreenWidth - 80)/3);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[QNVoiceChatRoomCell class] forCellWithReuseIdentifier:@"QNVoiceChatRoomCell"];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.masterSeat.mas_bottom).offset(10);
            make.height.mas_equalTo(((kScreenWidth - 80)/3)*2+20);
        }];
    }
    return _collectionView;
}

- (GiftView *)giftView{
    if (!_giftView) {
        _giftView = [[GiftView alloc] init];
        _giftView.delegate = self;
    }
    return _giftView;
}

- (QNBottomUserOperationView *)userOpetationView {
    if (!_userOpetationView) {
        _userOpetationView = [[QNBottomUserOperationView alloc]initWithAllowVideoOperation:NO];
        __weak typeof(self)weakSelf = self;
        _userOpetationView.forbiddenAudioBlock = ^(QNRTCMicsInfo * _Nonnull userInfo, BOOL forbiddenAudio) {
            QNIMMessageObject *message = [weakSelf.messageCreater createForbiddenAudio:forbiddenAudio userId:userInfo.uid msg:@""];
            [[QNIMChatService sharedOption] sendMessage:message];
        };
        _userOpetationView.kickOutMicBlock = ^(QNRTCMicsInfo * _Nonnull userInfo) {
            QNIMMessageObject *message = [weakSelf.messageCreater createKickOutMicMessageWithUid:userInfo.uid msg:@""];
            [[QNIMChatService sharedOption] sendMessage:message];
        };
    }
    return _userOpetationView;
}
@end

