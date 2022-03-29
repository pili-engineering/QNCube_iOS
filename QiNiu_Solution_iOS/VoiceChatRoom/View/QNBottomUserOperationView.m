//
//  QNBottomUserOperationView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/25.
//

#import "QNBottomUserOperationView.h"
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"

@interface QNBottomUserOperationView ()

@property (nonatomic, assign) BOOL allowForbiddenVideo;//是否允许关闭视频

@property (nonatomic, strong) QNRTCMicsInfo *userInfo;

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation QNBottomUserOperationView

- (instancetype)initWithAllowVideoOperation:(BOOL)isAllow
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        self.allowForbiddenVideo = isAllow;
        [self setUI];

    }
    return self;
}

- (void)showWithUserInfo:(QNRTCMicsInfo *)userInfo{
    
    self.userInfo = userInfo;
    NSData *JSONData = [userInfo.userExtension dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

    QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.userExtProfile.avatar]];
    self.nameLabel.text = user.userExtProfile.name;
    
    [self showView];    
}

- (void)setUI {
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 230, kScreenWidth, 230)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    self.avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight - 230 - 40, 80, 80)];
    self.avatarImageView.layer.cornerRadius = 40;
    self.avatarImageView.backgroundColor = [UIColor yellowColor];
    self.avatarImageView.clipsToBounds = YES;
    [self addSubview:self.avatarImageView];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kScreenHeight - 230 + 50, kScreenWidth, 20)];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = @"ggg";
    [self addSubview:self.nameLabel];
    
    NSArray *titles= @[@"闭麦",@"下麦"];
    NSArray *seletedTitles = @[@"开麦",@"下麦"];
    NSArray *selectors = @[@"forbiddenAudio:",@"kickOutMic:"];
    
    if (self.allowForbiddenVideo) {
        titles = @[@"闭麦",@"关视频", @"下麦"];
        seletedTitles = @[@"开麦",@"开视频", @"下麦"];
        selectors = @[@"forbiddenAudio:",@"forbiddenVideo:",@"kickOutMic:"];
    }
    CGFloat width = kScreenWidth/titles.count;
    for (int i = 0; i < titles.count; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width * i, kScreenHeight - 44, width, 44)];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitle:seletedTitles[i] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        SEL itemSelector = NSSelectorFromString(selectors[i]);
        [button addTarget:self action:itemSelector forControlEvents:(UIControlEventTouchUpInside)];
        button.selected = NO;
        [self addSubview:button];
    }
    
}

- (void)forbiddenAudio:(UIButton *)button {
    button.selected = !button.selected;
    if (self.forbiddenAudioBlock) {
        self.forbiddenAudioBlock(self.userInfo,button.selected);
    }
}

- (void)forbiddenVideo:(UIButton *)button {
    button.selected = !button.selected;
    if (self.forbiddenVideoBlock) {
        self.forbiddenVideoBlock(self.userInfo,button.selected);
    }
}

- (void)kickOutMic:(UIButton *)button {
    button.selected = !button.selected;    
    if (self.kickOutMicBlock) {
        self.kickOutMicBlock(self.userInfo);
    }
    [self hiddenView];
}

- (void)showView {    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }];
}

- (void)hiddenView {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {    
    [self hiddenView];
}



@end
