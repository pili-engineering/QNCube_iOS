//
//  QNSendMsgTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNMessageCreater.h"
#import "MicSeatMessageModel.h"
#import "IMTextMsgModel.h"
#import "InvitationModel.h"
#import "ForbiddenMicModel.h"
#import "QNDanmuMsgModel.h"
#import "GiftMsgModel.h"
#import "HeartMsgModel.h"
#import "QNRTCRoomEntity.h"
#import "IMModel.h"

@interface QNMessageCreater ()

@property(nonatomic, copy)NSString *toId;

@end

@implementation QNMessageCreater

- (instancetype)initWithToId:(NSString *)toId {
    if (self = [super init]) {
        self.toId = toId;
    }
    return self;
}

//生成加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage {
    
    QNIMMessageObject *message = [self messageWithAction:@"welcome" content:@"加入房间"];
    message.senderName = Get_Nickname;
    return message;
}

//生成离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage {
    
    QNIMMessageObject *message = [self messageWithAction:@"quit_room" content:@"离开房间"];
    return message;
    
}

//生成聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content {
    
    QNIMMessageObject *message = [self messageWithAction:@"pub_chat_text" content:content];
    return message;
    
}

//生成弹幕消息
- (QNIMMessageObject *)createDanmuMessage:(NSString *)content {

    QNDanmuMsgModel *danmu = [QNDanmuMsgModel new];
    danmu.content = content;
    danmu.senderName = Get_Nickname;
    danmu.senderUid = Get_User_id;
    danmu.senderAvatar = Get_avatar;
    danmu.senderRoomId = self.toId;
    
    IMModel *model = [IMModel new];
    model.action = @"living_danmu";
    model.data = danmu.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//生成礼物消息
- (QNIMMessageObject *)createGiftMessage:(QNGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg {
    
    GiftMsgModel *giftMsgModel = [GiftMsgModel new];
    giftMsgModel.senderUid = Get_User_id;
    giftMsgModel.senderName = Get_Nickname;
    giftMsgModel.senderAvatar = Get_avatar;
    giftMsgModel.senderRoomId = self.toId;
    giftMsgModel.sendGift = giftModel;
    giftMsgModel.number = number;
    giftMsgModel.extMsg = extMsg;
    
    IMModel *model = [IMModel new];
    model.action = @"living_gift";
    model.data = giftMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//生成点赞消息
- (QNIMMessageObject *)createHeartMessage:(NSInteger)count {
    
    HeartMsgModel *heartMsgModel = [HeartMsgModel new];
    heartMsgModel.count = count;
    heartMsgModel.senderName = Get_Nickname;
    heartMsgModel.senderUid = Get_User_id;
    heartMsgModel.senderRoomId = self.toId;
    
    IMModel *model = [IMModel new];
    model.action = @"living_heart";
    model.data = heartMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//发送上麦信令
- (QNIMMessageObject *)createOnMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitDown" openAudio:YES openVideo:YES];
    return message;
}

//发送下麦信令
- (QNIMMessageObject *)createDownMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitUp" openAudio:NO openVideo:NO];
    return message;
}

//开关麦信令（音频）
- (QNIMMessageObject *)createMicStatusMessage:(BOOL)openAudio {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_microphoneStatus" openAudio:openAudio openVideo:YES];
    return message;
}

//开关麦信令（视频）
- (QNIMMessageObject *)createCameraStatusMessage:(BOOL)openVideo {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_cameraStatus" openAudio:YES openVideo:openVideo];
    return message;
}

//禁麦音频
- (QNIMMessageObject *)createForbiddenAudio:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    QNIMMessageObject *message = [self createForbiddenMessageWithAction:@"rtc_forbiddenAudio" isFobidden:isForbidden userId:userId msg:msg];
    return message;
}

//禁麦视频
- (QNIMMessageObject *)createForbiddenVideo:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg{
    QNIMMessageObject *message = [self createForbiddenMessageWithAction:@"rtc_forbiddenVideo" isFobidden:isForbidden userId:userId msg:msg];
    return message;
}

//生成锁麦信令
- (QNIMMessageObject *)createLockMicMessageWithUid:(NSString *)uid msg:(NSString *)msg {
    
    MicSeatMessageModel *micSeat = [MicSeatMessageModel new];
    micSeat.ownerOpenAudio = NO;
    micSeat.ownerOpenVideo = NO;
    micSeat.uid = uid;
    
    QNIMSeatOperationModel *operaqtionModel = [QNIMSeatOperationModel new];
    operaqtionModel.seat = micSeat;
    operaqtionModel.msg = msg;
    
    IMModel *messageModel = [IMModel new];
    messageModel.action = @"rtc_lockSeat";
    messageModel.data = operaqtionModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//生成踢麦信令
- (QNIMMessageObject *)createKickOutMicMessageWithUid:(NSString *)uid msg:(NSString *)msg {
    
    MicSeatMessageModel *micSeat = [MicSeatMessageModel new];
    micSeat.ownerOpenAudio = NO;
    micSeat.ownerOpenVideo = NO;
    micSeat.uid = uid;
    
    QNIMSeatOperationModel *operaqtionModel = [QNIMSeatOperationModel new];
    operaqtionModel.seat = micSeat;
    operaqtionModel.msg = msg;
    
    IMModel *messageModel = [IMModel new];
    messageModel.action = @"rtc_kickOutFromMicSeat";
    messageModel.data = operaqtionModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//生成踢出房间信令
- (QNIMMessageObject *)createKickOutRoomMessage:(NSString *)uid msg:(NSString *)msg {
    
    MicSeatMessageModel *micSeat = [MicSeatMessageModel new];
    micSeat.uid = uid;
    micSeat.msg = msg;
    
    IMModel *messageModel = [IMModel new];
    messageModel.action = @"rtc_kickOutFromRoom";
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    return message;
}

//生成禁麦信令
- (QNIMMessageObject *)createForbiddenMessageWithAction:(NSString *)action isFobidden:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    ForbiddenMicModel *msgModel = [ForbiddenMicModel new];
    msgModel.uid = userId;
    msgModel.isForbidden = isForbidden;
    msgModel.msg = msg;
    
    IMModel *model = [IMModel new];
    model.action = action;
    model.data = msgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    
    return message;
}

//发送邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_send" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_cancel" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_accept" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_reject" invitationName:invitationName receiverId:receiverId];
    return message;
}

//生成邀请信令
- (QNIMMessageObject *)createInviteMessageWithAction:(NSString *)action invitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNInvitationInfo *info = [QNInvitationInfo new];
    info.channelId = self.toId;
    info.initiatorUid = Get_User_id;
    info.msg = [NSString stringWithFormat:@"用户 %@ 邀请你一起连麦，是否加入？",Get_Nickname];
    info.receiver =  receiverId;
    info.timeStamp = [self getNowTimeTimestamp3];
    
    InvitationModel *invitationData = [InvitationModel new];
    invitationData.invitationName = invitationName;
    invitationData.invitation = info;
    
    IMModel *model = [IMModel new];
    model.action = action;
    model.data = invitationData.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
}

//生成进房/离房/聊天消息
- (QNIMMessageObject *)messageWithAction:(NSString *)action content:(NSString *)content {
    
    IMTextMsgModel *model = [IMTextMsgModel new];
    model.senderName = Get_Nickname;
    model.senderId = Get_IM_ID;
    model.msgContent = content;
    
    IMModel *messageModel = [IMModel new];
    messageModel.action = action;
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
    
}

//上下麦信令
- (QNIMMessageObject *)sendMicMessage:(NSString *)action openAudio:(BOOL)openAudio openVideo:(BOOL)openVideo {

    IMModel *messageModel = [IMModel new];
    messageModel.action = action;
    
    MicSeatMessageModel *micSeat = [MicSeatMessageModel new];
    micSeat.ownerOpenAudio = openAudio;
    micSeat.ownerOpenVideo = openVideo;
    micSeat.uid = Get_User_id;
    
    QNUserExtension *user = [QNUserExtension new];
    user.uid = Get_User_id;
    
    QNUserExtProfile *profile = [QNUserExtProfile new];
    profile.name = Get_Nickname;
    profile.avatar = Get_avatar;
    
    user.userExtProfile = profile;
    
    micSeat.userExtension = user;
    
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:Get_IM_ID.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = Get_Nickname;
    return message;
    
}

- (NSString *)getNowTimeTimestamp3{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制

   NSTimeZone*timeZone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];

    return timeSp;

}

@end
