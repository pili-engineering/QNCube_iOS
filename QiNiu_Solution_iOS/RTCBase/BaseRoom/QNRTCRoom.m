//
//  QNRTCRoom.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNRTCRoom.h"
#import "QNRoomUserView.h"
#import "QNPageControl.h"

@interface QNRTCRoom ()
@property (nonatomic, strong) LogTableView *logTableView;//track传输信息tableview
@property (nonatomic, strong) QNPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *userViewArray;
@property (nonatomic, strong) NSMutableArray *logStringArray;
@property (nonatomic, strong) NSTimer *getstatsTimer;

@end

@implementation QNRTCRoom

- (void)dealloc {
    [QNRTC deinit];
}

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.logTableView.hidden = YES;
}

- (instancetype)initWithRoomModel:(QNRoomDetailModel *)model {
    if (self = [super init]) {
        self.model = model;
        [self roomRequest];
    }
    return self;
}

- (UIButton *)logButton {
    if (!_logButton) {
        _logButton = [[UIButton alloc] init];
        [_logButton setImage:[UIImage imageNamed:@"log-btn"] forState:(UIControlStateNormal)];
        [_logButton addTarget:self action:@selector(logAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:_logButton];
        [_logButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.mas_topLayoutGuide).offset(10);
        }];
    }
    return _logButton;
}

- (void)logAction:(UIButton *)button {
    button.selected = !button.isSelected;
    if (button.selected) {
        if ([self.logTableView numberOfRowsInSection:0] != self.logStringArray.count) {
            [self.logTableView reloadData];
        }
    }
    self.logTableView.hidden = !button.selected;
}

#pragma mark ------房间操作

//有传入房间model参数的情况下直接加入房间
- (void)joinRoom {
    QNRTCRoomEntity *room = [QNRTCRoomEntity new];
    room.providePushUrl = self.model.rtcInfo.publishUrl;
    room.provideRoomToken = self.model.rtcInfo.roomToken;
    room.provideHostUid = self.model.roomInfo.creator;
    
    room.provideMeId = Get_User_id;
    
    QNUserExtension *userInfo = [QNUserExtension new];
    userInfo.userExtRoleType = self.model.userInfo.role;
    room.provideUserExtension = userInfo;
    
    [self joinRoom:room];
}

- (void)joinRoom:(QNRTCRoomEntity *)roomEntity {
    [super joinRoom:roomEntity];
}
- (void)leaveRoom {
    [super leaveRoom];
}

#pragma mark ------轨道参数设置

//本地音频轨道参数
- (void)setUpLocalAudioTrackParams:(QNAudioTrackParams *)audioTrackParams{
    
    [self.localAudioTrack setVolume:audioTrackParams.volume];
}
//本地视频轨道参数
- (void)setUpLocalVideoParams:(QNVideoTrackParams *)videoTrackParams{
    CGSize videoEncodeSize = CGSizeMake(videoTrackParams.width, videoTrackParams.height);
    
    QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:400*1000 videoEncodeSize:videoEncodeSize videoFrameRate:15];
    QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" config:config multiStreamEnable:NO];    
    self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
    [self.localVideoTrack play:self.preview];
    self.localVideoTrack.videoFrameRate = videoTrackParams.fps;
    self.localVideoTrack.previewMirrorFrontFacing = NO;
    [self.localVideoTrack startCapture];
    [self.localVideoTrack play:self.preview];
}
//设置屏幕共享参数
- (void)setScreenTrackParams:(QNVideoTrackParams *)params{
    
    if (![QNScreenVideoTrack isScreenRecorderAvailable]) {
        [MBProgressHUD showText:@"当前设备不支持屏幕录制"];
        return;;
    }
    // 视频
    CGSize videoEncodeSize = CGSizeMake(params.width, params.height);
    QNVideoEncoderConfig *config = [[QNVideoEncoderConfig alloc] initWithBitrate:400*1000 videoEncodeSize:videoEncodeSize videoFrameRate:15];
    QNScreenVideoTrackConfig * screenConfig = [[QNScreenVideoTrackConfig alloc] initWithSourceTag:@"screen" config:config multiStreamEnable:NO];
    self.localScreenTrack = [QNRTC createScreenVideoTrackWithConfig:screenConfig];

}

#pragma mark ------本地音视频操作

//启用视频模块
- (void)enableVideo{
    [self.localVideoTrack startCapture];
}

//不启用视频模块
- (void)disableVideo{
    [self.localVideoTrack stopCapture];
}

//切换前后摄像头
- (void)switchCamera{
    [self.localVideoTrack switchCamera];
}

//开关本地摄像头
- (void)muteLocalVideo:(BOOL)mute{
    [self.localVideoTrack updateMute:mute];
}

//开关本地音频
- (void)muteLocalAudio:(BOOL)mute{    
    [self.localAudioTrack updateMute:mute];
}

//发布本地屏幕共享
- (void)pubLocalScreenTrack{
    [self.rtcClient publish:@[self.localScreenTrack]];
}

//取消发布本地视频共享
- (void)unPubLocalScreenTrack{
    [self.rtcClient unpublish:@[self.localScreenTrack]];
}

#pragma mark ------远端音视频操作

//屏蔽远端某用户的视频流
- (void)muteRemoteVideo:(NSString *)uid mute:(BOOL)mute{
    
}
//屏蔽远端某用户的音频流
- (void)muteRemoteAudio:(NSString *)uid mute:(BOOL)mute{
    
}

//屏蔽所有用户音频
- (void)muteAllRemoteAudio:(BOOL)mute{
    
}
//屏蔽所有用户视频
- (void)muteAllRemoteVideo:(BOOL)mute{
    
}

//添加rtc事件监听
- (void)addExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener{
    
}
//移除rtc事件监听
- (void)removeExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener{
    
}

//设置美颜参数
- (void)setDefaultBeauty:(NSDictionary *)beautySetting{
    
}

//设置预览窗口
- (void)setlocalCameraWindowView:(UIView *)faceView{
    
}

- (void)setUserCameraWindowView:(UIView *)faceView uid:(NSString *)uid{
    
}
- (void)setUserScreenWindowView:(UIView *)faceView uid:(NSString *)uid{
    
}
- (void)setUserExtraTrackWindowView:(UIView *)faceView uid:(NSString *)uid trackTag:(NSString *)trackTag{
    
}

//获取混流器
- (void)getMixStreamHelper{
    
}

//获取用户视频Track
- (QNTrackInfo *)getUserVideoTrackInfo:(NSString *)uid{
    return nil;
}
//获取用户音频Track
- (QNTrackInfo *)getUserAudioTrackInfo:(NSString *)uid{
    return nil;
}
//获取用户屏幕共享Track
- (QNTrackInfo *)getUserScreenTrackInfo:(NSString *)uid{
    return nil;
}
//获取自定义Track
- (QNTrackInfo *)getUserExtraTrackInfo:(NSString *)uid extraTrackTag:(NSString *)extraTrackTag{
    return nil;
}

- (NSArray <QNTrack *> *)getTracksWithUser:(NSString *)userID {
    QNRemoteUser *user = [self.rtcClient getRemoteUser:userID];
    NSMutableArray *tracks = [[NSMutableArray alloc]initWithArray:user.videoTrack];
    [tracks addObjectsFromArray:user.audioTrack];
    return tracks;
}

//是否是房主
- (BOOL)isAdminUser:(NSString *)userId {
    BOOL isAdmin = NO;
    if ([userId isEqualToString:self.model.roomInfo.creator]) {
        isAdmin = YES;
    }
    return isAdmin;
}

- (BOOL)isAdmin {
    BOOL isAdmin = NO;
    if ([self.model.roomInfo.creator isEqualToString:Get_User_id]) {
        isAdmin = YES;
    }
    return isAdmin;
}

- (void)clearUserInfo:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = self.userViewArray.count - 1; i >= 0; i--) {
            QNRoomUserView *userView = self.userViewArray[i];
            if ([userView.userId isEqualToString:userId]) {
                [userView removeFromSuperview];
            }
        }
        [self resetRenderViews];
    });
}

- (void)clearAllRemoteUserInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = self.userViewArray.count - 1; i >= 0; i--) {
            QNRoomUserView *userView = self.userViewArray[i];
            [userView removeFromSuperview];
        }

        [self resetRenderViews];
    });
}

#pragma mark - 预览画面设置

- (void)resetRenderViews {
    @synchronized (self) {
        
        NSArray<QNRoomUserView *> *allRenderView = self.renderBackgroundView.subviews;
        
        if (1 == allRenderView.count) {
            self.pageControl.hidden = YES;
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
        } else if (2 == allRenderView.count) {
            self.pageControl.hidden = YES;
            
            for (QNRoomUserView *view in allRenderView) {
                if ([view.class isEqual:[QNRoomUserView class]]) {
                    view.showNameLabel = NO;
                    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view);
                    }];
                }
            }
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:self.preview];
        }else if (3 == allRenderView.count) {
            self.pageControl.hidden = NO;
            self.pageControl.currentPage = 0;
            //对方屏幕分享
            QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
            removeScreenView.showNameLabel = NO;
            //添加左滑手势
            UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe)];
            [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
            removeScreenView.userInteractionEnabled = YES;
            [removeScreenView addGestureRecognizer:leftRecognizer];
            [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            //自己的视图
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            
            //对方视图
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
            removeCameraView.showNameLabel = NO;
            //添加右滑手势
            UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe)];
            [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
            removeCameraView.userInteractionEnabled = YES;
            [removeCameraView addGestureRecognizer:rightRecognizer];
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:removeScreenView];
            [self.renderBackgroundView bringSubviewToFront:self.preview];
            
        } else {
                    
            int col = ceil(sqrt(allRenderView.count));
            
            UIView *preView = nil;
            UIView *upView = nil;
            for (int i = 0; i < allRenderView.count; i ++) {
                UIView *view = allRenderView[i];
                [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(preView ? preView.mas_right : self.renderBackgroundView);
                    make.top.equalTo(upView ? upView.mas_bottom : self.renderBackgroundView);
                    make.width.equalTo(self.renderBackgroundView).multipliedBy(1.0/col);
                    //                make.size.equalTo(self.renderBackgroundView).multipliedBy(1.0/col);
                    make.height.mas_equalTo(view.width);
                }];
                
                if ((i + 1) % col == 0) {
                    preView = nil;
                    upView = view;
                } else {
                    preView = view;
                }
            }
        }
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)leftSwipe {
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];

//    if (self.pageControl.currentPage == 0 && self.engine.previewView.frame.size.width == kScreenWidth) {
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        self.pageControl.currentPage = 1;
//        return;
//    }
//    if (self.pageControl.currentPage == 1 && self.engine.previewView.frame.size.width == kScreenWidth){
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        self.pageControl.currentPage = 0;
//        return;
//    }
    
    [self.renderBackgroundView bringSubviewToFront:removeCameraView];
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pageControl.currentPage = 1;
    
}

- (void)rightSwipe {
    
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
    
//    if (self.pageControl.currentPage == 0 && self.engine.previewView.frame.size.width == kScreenWidth) {
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        self.pageControl.currentPage = 1;
//        return;
//    }
//    if (self.pageControl.currentPage == 1 && self.engine.previewView.frame.size.width == kScreenWidth){
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        self.pageControl.currentPage = 0;
//        return;
//    }
    
    [self.renderBackgroundView bringSubviewToFront:removeScreenView];
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pageControl.currentPage = 0;
}

// 大小窗口切换
- (void)exchangeWindowSize {
    
    if (self.renderBackgroundView.subviews.count == 2) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
        
        if (CGRectContainsRect(removeCameraView.frame, self.preview.frame)) {
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            removeCameraView.showNameLabel = YES;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            
        } else {
            removeCameraView.showNameLabel = NO;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:self.preview];
        }
    } else if (self.renderBackgroundView.subviews.count == 3) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
        QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
        
        if (self.pageControl.currentPage == 0) {
            
            if (CGRectContainsRect(removeScreenView.frame, self.preview.frame)){
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeScreenView.showNameLabel = YES;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeScreenView];
            } else {
                removeScreenView.showNameLabel = NO;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.preview];
            }
            
            
        } else {
            if (CGRectContainsRect(removeCameraView.frame, self.preview.frame)){
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeCameraView.showNameLabel = YES;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            } else {
                removeCameraView.showNameLabel = NO;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.preview];
            }
        }
        
    }
    
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)addLogString:(NSString *)logString {
//    NSLog(@"%@", logString);
    
    @synchronized(_logStringArray) {
        [self.logStringArray addObject:logString];
    }
    
    dispatch_main_async_safe(^{
        // 只有日志 view 是显示的时候，才去更新 UI
        if (!self.logTableView.hidden) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self.logTableView selector:@selector(reloadData) object:nil];
            [self.logTableView performSelector:@selector(reloadData) withObject:nil afterDelay:.2];
        }
    });
}


- (void)clearLogString {
    
    @synchronized(_logStringArray) {
        [_logStringArray removeAllObjects];
    }
    
    dispatch_main_async_safe(^{
        [self.logTableView reloadData];
    });
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    @synchronized(_logStringArray) {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @synchronized(_logStringArray) {
        return _logStringArray.count;
    }
}

static const int cLabelTag = 10;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"reuseIdentifier"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = cLabelTag;
        
        [cell.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(cell.contentView).offset(5);
            make.right.bottom.equalTo(cell.contentView).offset(-5);
            
        }];
    }
    
    UILabel *label = [cell.contentView viewWithTag:cLabelTag];
    @synchronized(_logStringArray) {
        if (_logStringArray.count > indexPath.row) {
            label.text = _logStringArray[indexPath.row];
        } else {
            label.text = @"Unknown message";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.logTableView.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.logTableView.isScrolling = decelerate;
    if (!decelerate) {
        CGFloat offset = fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y);
//        NSLog(@"value = %f", offset);
        // 这里小于 10 就算到底部了
        self.logTableView.isBottom =  offset < 10;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.logTableView.isScrolling = NO;
    
    CGFloat offset = fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y);
//    NSLog(@"value = %f", offset);
    // 这里小于 10 就算到底部了
    self.logTableView.isBottom =  offset < 10;
}

#pragma mark - 统计信息计算

- (void)startGetStatsTimer {
    
    [self stopGetStatsTimer];
    
    self.getstatsTimer = [NSTimer timerWithTimeInterval:3
                                             target:self
                                           selector:@selector(getStatesTimerAction)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.getstatsTimer forMode:NSRunLoopCommonModes];
}

- (void)getStatesTimerAction {
    if (QNConnectionStateConnected != self.rtcClient.connectionState && QNConnectionStateReconnected != self.rtcClient.connectionState) {
        return;
    }
        
    NSDictionary* videoTrackStats =  [[NSDictionary alloc] initWithDictionary:[self.rtcClient getLocalVideoTrackStats]];
    
    for (NSString * trackID in videoTrackStats.allKeys) {
        NSString *str = nil;
        QNLocalVideoTrackStats * videoStats = videoTrackStats[trackID];
        str = [NSString stringWithFormat:@"本地视频传输信息:\ntrackID：%@\n\n视频码率：%2fbps\n 本地视频丢包率：%f%%\n视频帧率：%ld\n本地 rtt：%ld\nprofile：%ld\n",trackID, videoStats.uplinkBitrate, videoStats.uplinkLostRate, videoStats.uplinkFrameRate, videoStats.uplinkRTT, videoStats.profile];
        [self addLogString:str];
    }
    
    NSDictionary* audioTrackStats =  [self.rtcClient getLocalAudioTrackStats];
    for (NSString * trackID in audioTrackStats.allKeys) {
        NSString *str = nil;
        QNLocalAudioTrackStats * audioState = audioTrackStats[trackID];
        str = [NSString stringWithFormat:@"本地音频统计信息:\ntrackID：%@\n音频码率：%.2fbps\n音频丢包率：%f%%\n本地 rtt：%ld\n",trackID, audioState.uplinkBitrate, audioState.uplinkLostRate,audioState.uplinkRTT];
        [self addLogString:str];
    }
    
    NSDictionary* videoRemoteTrackStats =  [self.rtcClient getRemoteVideoTrackStats];
    for (NSString * trackID in videoRemoteTrackStats.allKeys) {
        NSString *str = nil;
        QNRemoteVideoTrackStats * videoStats = videoRemoteTrackStats[trackID];
        str = [NSString stringWithFormat:@"远端视频传输信息:\ntrackID：%@\n视频码率：%2fbps\n远端服务器视频丢包率：%f%%\n视频帧率：%@\n远端user视频丢包率：%f%%\n远端 rtt：%ld\n", trackID,videoStats.downlinkBitrate, videoStats.uplinkLostRate, @(videoStats.downlinkFrameRate), videoStats.downlinkLostRate, videoStats.uplinkRTT];
        [self addLogString:str];
    }
    
    NSDictionary* audioRemoteTrackStats =  [self.rtcClient getRemoteAudioTrackStats];
    for (NSString * trackID in audioRemoteTrackStats.allKeys) {
        NSString *str = nil;
        QNRemoteAudioTrackStats * audioState = audioRemoteTrackStats[trackID];
        str = [NSString stringWithFormat:@"远端音频传输信息:\ntrackID：%@\n音频码率：%2fbps\n远端服务器音频丢包率：%f%%\n远端user音频丢包率：%f%%\n远端 rtt：%lu\n", trackID,audioState.downlinkBitrate, audioState.downlinkLostRate,audioState.uplinkLostRate,(unsigned long)audioState.uplinkRTT];
        [self addLogString:str];
    }
    
    NSLog(@"aaron localCount:%ld localAudioCount:%ld remoteVideo:%ld remoteAudio:%lu",videoTrackStats.count,audioTrackStats.count,videoRemoteTrackStats.count,(unsigned long)audioRemoteTrackStats.count);
}

- (void)stopGetStatsTimer {
    if (self.getstatsTimer) {
        [self.getstatsTimer invalidate];
        self.getstatsTimer = nil;
    }
}

/**
 * 房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可
 */
- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    NSDictionary *roomStateDictionary =  @{
                                           @(QNConnectionStateDisconnected) : @"Idle",
                                           @(QNConnectionStateConnecting) : @"Connecting",
                                           @(QNConnectionStateConnected): @"Connected",
                                           @(QNConnectionStateReconnecting) : @"Reconnecting",
                                           @(QNConnectionStateReconnected) : @"Reconnected"
                                           };
    NSString *str = [NSString stringWithFormat:@"房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可:\nroomState: %@\ninfo:%d",  roomStateDictionary[@(state)], info.reason];
    if (QNConnectionStateConnected == state || QNConnectionStateReconnected == state) {
        [self startGetStatsTimer];
    } else {
        [self stopGetStatsTimer];
    }
    [self addLogString:str];
    if (QNConnectionStateDisconnected == state) {
        switch (info.reason) {
            case QNConnectionDisconnectedReasonKickedOut:{
                str =[NSString stringWithFormat:@"被远端服务器踢出的回调"];
                [self addLogString:str];
            }
                break;
            case QNConnectionDisconnectedReasonLeave:{
                str = [NSString stringWithFormat:@"本地用户离开房间"];
                [self addLogString:str];
            }
                break;
                
            default:{
                str = [NSString stringWithFormat:@"SDK 运行过程中发生错误会通过该方法回调，具体错误码的含义可以见 QNTypeDefines.h 文件:\nerror: %@",  info.error];
                [self addLogString:str];
                switch (info.error.code) {
                    case QNRTCErrorAuthFailed:
                        NSLog(@"鉴权失败，请检查鉴权");
                        break;
                    case QNRTCErrorTokenError:
                        //关于 token 签算规则, 详情请参考【服务端开发说明.RoomToken 签发服务】https://doc.qnsdk.com/rtn/docs/server_overview#1
                        NSLog(@"roomToken 错误");
                        break;
                    case QNRTCErrorTokenExpired:
                        NSLog(@"roomToken 过期");
                        break;
//                    case QNRTCErrorReconnectTokenError:
//                        NSLog(@"重新进入房间超时，请务必调用 leave, 重新进入房间");
//                        break;
                    default:
                        break;
                }
            }
                break;
        }
    }

}


- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if (![[self.renderBackgroundView subviews] containsObject:renderView]) {
            [self.renderBackgroundView addSubview:renderView];
            [self resetRenderViews];
        }
    }
}

- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if ([[self.renderBackgroundView subviews] containsObject:renderView]) {
            [renderView removeFromSuperview];
            [self resetRenderViews];
        }
    }
}

- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId {
    QNRoomUserView *userView = [[QNRoomUserView alloc] init];
    userView.userId = userId;
    userView.trackId = trackId;
    return userView;
}

- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId {
    @synchronized(self.userViewArray) {
        for (QNRoomUserView *userView in self.renderBackgroundView.subviews) {
            if ([userView.class isEqual:[QNVideoGLView class]]) {
                return nil;
            }
            if ([userView.trackId isEqualToString:trackId]) {
                return userView;
            }
        }
    }
    return nil;
}

- (NSMutableArray *)userViewArray {
    if (!_userViewArray) {
        _userViewArray = [NSMutableArray arrayWithArray:self.renderBackgroundView.subviews];
    }
    return _userViewArray;
}

- (LogTableView *)logTableView {
    if (!_logTableView) {
        _logTableView = [[LogTableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _logTableView.delegate = self;
        _logTableView.dataSource = self;
        _logTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.3];
        _logTableView.separatorColor = [UIColor clearColor];
        _logTableView.isBottom = YES;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_logTableView];
        
        [_logTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(window).offset(50);
            make.top.equalTo(self.mas_topLayoutGuide).offset(40);
            make.right.equalTo(window).offset(-40);
            make.height.mas_equalTo(400);
        }];
        
        _logTableView.hidden = YES;
    }
    return _logTableView;
}

- (NSMutableArray *)logStringArray {
    if (!_logStringArray) {
        _logStringArray = [[NSMutableArray alloc] init];
    }
    return _logStringArray;
}

-(QNMessageCreater *)messageCreater {
    if (!_messageCreater) {
        _messageCreater = [[QNMessageCreater alloc]initWithToId:self.model.imConfig.imGroupId];
    }
    return _messageCreater;
}

- (QNRoomRequest *)roomRequest {
    if (!_roomRequest) {
        _roomRequest = [[QNRoomRequest alloc]initWithType:self.model.roomType roomId:self.model.roomInfo.roomId];
    }
    return _roomRequest;
}

- (QNMixStreamManager *)mixManager {
    if (!_mixManager) {
        _mixManager = [[QNMixStreamManager alloc]initWithPushUrl:self.model.rtcInfo.publishUrl client:self.rtcClient streamID:self.model.roomInfo.roomId];
    }
    return _mixManager;
}

@end
