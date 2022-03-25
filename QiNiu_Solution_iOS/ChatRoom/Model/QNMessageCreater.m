//
//  QNSendMsgTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNMessageCreater.h"
#import "QNMicSeatMessageModel.h"
#import "QNIMTextMsgModel.h"
#import "QNInvitationModel.h"
#import "QNForbiddenMicModel.h"
#import "QNDanmuMsgModel.h"
#import "QNGiftMsgModel.h"
#import "QNHeartMsgModel.h"
#import "QNRTCRoomEntity.h"
#import "QNIMModel.h"

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
    danmu.senderName = QN_User_nickname;
    danmu.senderUid = QN_User_id;
    danmu.senderAvatar = QN_User_avatar;
    danmu.senderRoomId = self.toId;
    
    QNIMModel *model = [QNIMModel new];
    model.action = @"living_danmu";
    model.data = danmu.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成礼物消息
- (QNIMMessageObject *)createGiftMessage:(QNGiftModel *)giftModel number:(NSInteger)number extMsg:(NSString *)extMsg {
    
    QNGiftMsgModel *giftMsgModel = [QNGiftMsgModel new];
    giftMsgModel.senderUid = QN_User_id;
    giftMsgModel.senderName = QN_User_nickname;
    giftMsgModel.senderAvatar = QN_User_avatar;
    giftMsgModel.senderRoomId = self.toId;
    giftMsgModel.sendGift = giftModel;
    giftMsgModel.number = number;
    giftMsgModel.extMsg = extMsg;
    
    QNIMModel *model = [QNIMModel new];
    model.action = @"living_gift";
    model.data = giftMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成点赞消息
- (QNIMMessageObject *)createHeartMessage:(NSInteger)count {
    
    QNHeartMsgModel *heartMsgModel = [QNHeartMsgModel new];
    heartMsgModel.count = count;
    heartMsgModel.senderName = QN_User_nickname;
    heartMsgModel.senderUid = QN_User_id;
    heartMsgModel.senderRoomId = self.toId;
    
    QNIMModel *model = [QNIMModel new];
    model.action = @"living_heart";
    model.data = heartMsgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//发送上麦信令
- (QNIMMessageObject *)createOnMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitDown"];
    return message;
}

//发送下麦信令
- (QNIMMessageObject *)createDownMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitUp"];
    return message;
}

//禁止音频
- (QNIMMessageObject *)createForbiddenAudio:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    QNIMMessageObject *message = [self createForbiddenMessageWithAction:@"rtc_forbiddenAudio" isFobidden:isForbidden userId:userId msg:msg];
    return message;
}

//禁止视频
- (QNIMMessageObject *)createForbiddenVideo:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg{
    QNIMMessageObject *message = [self createForbiddenMessageWithAction:@"rtc_forbiddenVideo" isFobidden:isForbidden userId:userId msg:msg];
    return message;
}

//生成锁麦信令
- (QNIMMessageObject *)createLockMicMessageWithUid:(NSString *)uid msg:(NSString *)msg {
    
    QNMicSeatMessageModel *micSeat = [QNMicSeatMessageModel new];
    micSeat.ownerOpenAudio = NO;
    micSeat.ownerOpenVideo = NO;
    micSeat.uid = uid;
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = @"rtc_lockSeat";
    messageModel.msg = msg;
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成踢麦信令
- (QNIMMessageObject *)createKickOutMicMessageWithUid:(NSString *)uid msg:(NSString *)msg {
    
    QNMicSeatMessageModel *micSeat = [QNMicSeatMessageModel new];
    micSeat.ownerOpenAudio = NO;
    micSeat.ownerOpenVideo = NO;
    micSeat.uid = uid;
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = @"rtc_kickOutFromMicSeat";
    messageModel.msg = msg;
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成踢出房间信令
- (QNIMMessageObject *)createKickOutRoomMessage:(NSString *)uid msg:(NSString *)msg {
    
    QNMicSeatMessageModel *micSeat = [QNMicSeatMessageModel new];
    micSeat.uid = uid;
    micSeat.msg = msg;
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = @"rtc_kickOutFromRoom";
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    return message;
}

//生成禁麦信令
- (QNIMMessageObject *)createForbiddenMessageWithAction:(NSString *)action isFobidden:(BOOL)isForbidden userId:(NSString *)userId msg:(NSString *)msg {
    
    QNIMModel *model = [QNIMModel new];
    model.action = action;
    
    QNForbiddenMicModel *msgModel = [QNForbiddenMicModel new];
    msgModel.uid = userId;
    msgModel.isForbidden = isForbidden;
    msgModel.msg = msg;
    
    model.data = msgModel.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    
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
    
    QNIMModel *model = [QNIMModel new];
    model.action = action;
    
    QNInvitationModel *invitationData = [QNInvitationModel new];
    invitationData.invitationName = invitationName;
    
    QNInvitationInfo *info = [QNInvitationInfo new];
    info.channelId = self.toId;
    info.initiatorUid = QN_User_id;
    info.msg = [NSString stringWithFormat:@"用户 %@ 邀请你一起连麦，是否加入？",QN_User_nickname];
    info.receiver =  receiverId;
    info.timeStamp = [self getNowTimeTimestamp3];
    
    invitationData.invitation = info;
    
    model.data = invitationData.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成进房/离房/聊天消息
- (QNIMMessageObject *)messageWithAction:(NSString *)action content:(NSString *)content {
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = action;
    
    QNIMTextMsgModel *model = [QNIMTextMsgModel new];
    
    model.senderName = QN_User_nickname;
    model.senderId = QN_IM_userId;
    model.msgContent = content;
    
    messageModel.data = model.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
    
}

//上下麦信令
- (QNIMMessageObject *)sendMicMessage:(NSString *)action {
    
    QNIMModel *messageModel = [QNIMModel new];
    messageModel.action = action;
    
    QNMicSeatMessageModel *micSeat = [QNMicSeatMessageModel new];
    micSeat.ownerOpenAudio = YES;
    micSeat.ownerOpenVideo = YES;
    micSeat.uid = QN_User_id;
    
    QNUserExtension *user = [QNUserExtension new];
    user.uid = QN_User_id;
    
    QNUserExtProfile *profile = [QNUserExtProfile new];
    profile.name = QN_User_nickname;
    profile.avatar = QN_User_avatar;
    
    user.userExtProfile = profile;
    
    micSeat.userExtension = user;
    
    messageModel.data = micSeat.mj_keyValues;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
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
