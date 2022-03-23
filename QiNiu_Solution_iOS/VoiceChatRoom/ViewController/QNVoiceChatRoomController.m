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
#import "QNIMMessageModel.h"
#import <YYCategories/YYCategories.h>
#import "QNChatRoomView.h"
#import "QNApplyOnSeatView.h"
#import "QNRoomRequest.h"
#import "QNMessageCreater.h"
#import "QNAlertViewController.h"
#import "QNVoiceChatRoomCell.h"
#import "QNInvitationModel.h"
#import "QNVoiceChatBottomOperationView.h"

@interface QNVoiceChatRoomController ()<QNRTCClientDelegate,QNIMChatServiceProtocol,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) QNChatRoomView * chatRoomView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *masterSeat;//房主座位

@property (nonatomic, strong) NSMutableArray <QNUserInfo *> *allUserList;

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
    bottomButtonView.textBlock = ^(NSString * _Nonnull text) {
        QNIMMessageObject *message = [weakSelf.messageCreater createChatMessage:text];
        [[QNIMChatService sharedOption] sendMessage:message];
        [weakSelf.chatRoomView sendMessage:message];
    };
    [self.view addSubview:bottomButtonView];
}

- (void)quitRoom {
    if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
        [QNAlertViewController showBaseAlertWithTitle:@"确定要关闭房间？" content:@"关闭房间后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
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
        self.allUserList = self.model.allUserList;
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
        self.allUserList = roomDetailodel.allUserList;
        
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

//离开房间
- (void)requestLeave {
    
    QNIMMessageObject *message = [self.messageCreater createLeaveRoomMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    [self.roomRequest requestDownMicSeat];
    [self.roomRequest requestLeaveRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self leaveRoom];
        
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    if (state == QNConnectionStateConnected) {
        
        if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
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
            [QNAlertViewController showBaseAlertWithTitle:@"房间已解散" content:@"房主离开后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
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

- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
    
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    QNIMMessageModel *messageModel = [QNIMMessageModel mj_objectWithKeyValues:messages.firstObject.content];
    
    __weak typeof(self)weakSelf = self;
    if ([messageModel.action isEqualToString:@"invite_send"]) {//连麦邀请消息
        
        QNInvitationModel *model = [QNInvitationModel mj_objectWithKeyValues:messages.firstObject.content];
        
        [QNAlertViewController showBlackAlertWithTitle:@"邀请提示" content:model.data.invitation.msg cancelHandler:^(UIAlertAction * _Nonnull action) {
             QNIMMessageObject *message = [weakSelf.messageCreater createRejectInviteMessageWithInvitationName:@"audioroomupmic" receiverId:model.data.invitation.initiatorUid];
            [[QNIMChatService sharedOption] sendMessage:message];
            
            [weakSelf getRoomMicInfo];
            
        } confirmHandler:^(UIAlertAction * _Nonnull action) {
                    
            QNIMMessageObject *message = [weakSelf.messageCreater createAcceptInviteMessageWithInvitationName:@"audioroomupmic" receiverId:model.data.invitation.initiatorUid];
           [[QNIMChatService sharedOption] sendMessage:message];
            [weakSelf getRoomMicInfo];
        }];
        
    } else if ([messageModel.action isEqualToString:@"invite_reject"]) {//连麦被拒绝消息
        
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
    }
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
}

//判断是否已经在麦上
- (BOOL)isOnMic {
    if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
        return YES;
    }
    for (QNRTCMicsInfo  *mic in self.onMicUserList) {
        if ([QN_User_id isEqualToString:mic.uid]) {
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

@end

