//
//  QNAppStartPlayerController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNAppStartPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <YYCategories/YYCategories.h>
#import "QNLoginViewController.h"
#import "QNTabBarViewController.h"

@interface QNAppStartPlayerController ()

@property (nonatomic, strong)AVPlayerViewController *AVPlayer;
@property (nonatomic, strong)UIButton *enterMainButton;
@property (nonatomic, assign) int timeCount;
@property (nonatomic, weak)NSTimer *timer;
@property (nonatomic, weak)NSTimer *timer1;


@end

@implementation QNAppStartPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setMoviePlayerInIndexWithURL:(NSURL *)movieURL localMovieName:(NSString *)localMovieName
{
    self.AVPlayer = [[AVPlayerViewController alloc]init];
    // 取消多分屏功能
    self.AVPlayer.allowsPictureInPicturePlayback = NO;
    self.AVPlayer.showsPlaybackControls = false;
    AVPlayerItem *item;
    if (movieURL) {
        NSLog(@"传入了网络视频url过来");
        item = [[AVPlayerItem alloc]initWithURL:movieURL];
    }else if (localMovieName) {
        NSLog(@"加载的是本地的视频");
        NSString *path =  [[NSBundle mainBundle] pathForResource:@"movie.mp4" ofType:nil];
        NSLog(@"path---%@", path);
        item = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:path]];
    }
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    // layer
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    [layer setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    // 填充模式
//    layer.videoGravity = AVLayerVideoGravityResizeAspect; // 保持视频的纵横比
    layer.videoGravity = AVLayerVideoGravityResize; // 填充整个屏幕
    self.AVPlayer.player = player;
    [self.view.layer addSublayer:layer];
    [self.AVPlayer.player play];
    
    // 重复播放。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];
//    [self createLoginBtn]; // 3秒后自动就停止(这里自行选择)
    [self createLoginBtn1]; // 不点的话 就一直播放视频
    
}

- (void)setImageInIndexWithURL:(NSURL *)imageURL localImageName:(NSString *)localImageName timeCount:(int)timeCount{
    
    _timeCount = timeCount;
    UIImageView *imagev1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    if (imageURL) {
//        NSLog(@"加载的是网络上的图片");
//        NSData *data = [NSData dataWithContentsOfURL:imageURL];
//        UIImage *image1 = [UIImage imageWithData:data];
//        imagev1.image = image1;
//
//    } else {
        NSLog(@"加载的是本地的图片");
        UIImage *image = [UIImage imageNamed:localImageName];
        imagev1.image = image;
//    }
    
    [self.view addSubview:imagev1];
    [self createLoginBtn];
}

// 播放完成代理
- (void)playDidEnd:(NSNotification *)Notification{
    // 重新播放
    [self.AVPlayer.player seekToTime:CMTimeMake(0, 1)];
    [self.AVPlayer.player play];
}

// 用户不用点击, 几秒后自动进入程序
- (void)createLoginBtn
{
    // 进入按钮
    _enterMainButton = [[UIButton alloc] init];
    _enterMainButton.frame = CGRectMake(kScreenWidth - 90, 50, 60, 30);
    _enterMainButton.backgroundColor = [UIColor grayColor];
    _enterMainButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _enterMainButton.layer.cornerRadius = 15;
    NSString *title = [NSString stringWithFormat:@"跳过 %d", _timeCount];
    [_enterMainButton setTitle:title forState:UIControlStateNormal];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DaoJiShi) userInfo:nil repeats:YES];
    [self.view addSubview:_enterMainButton];
    [_enterMainButton addTarget:self action:@selector(enterMainAction) forControlEvents:UIControlEventTouchUpInside];
}
// 倒计时
- (void)DaoJiShi{
    if (_timeCount > 1) {
        _timeCount -= 1;
        NSString *title = [NSString stringWithFormat:@"跳过 %d", _timeCount];
        [_enterMainButton setTitle:title forState:UIControlStateNormal];
    }else{
        [_timer invalidate];
        _timer = nil;
        [self enterMainAction];
    }
}

// 不会自动停止, 需要用户点击按钮才能进入应用
- (void)createLoginBtn1{ // 这里的时间是3秒后视频页面出现按钮
    _timer1 = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showClickBtn) userInfo:nil repeats:YES];
}
- (void)showClickBtn{
    NSLog(@"显示进入应用按钮");
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(30, kScreenHeight - 100, kScreenWidth - 60, 40);
    btn.backgroundColor = [UIColor redColor];
    btn.layer.cornerRadius = 20;
    btn.alpha = 0.5;
    [btn setTitle:@"进入应用" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(enterMainAction) forControlEvents:UIControlEventTouchUpInside];
    [_timer1 invalidate];
    _timer1 = nil;// timer置为nil

}

- (void)enterMainAction{
    
    NSString *loginToken = [[NSUserDefaults standardUserDefaults] stringForKey:QN_LOGIN_TOKEN_KEY];
    
    if (loginToken.length == 0) {
        QNLoginViewController *loginVC = [[QNLoginViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.view.window.rootViewController = navigationController;
    } else {
        QNTabBarViewController *tabBarVc = [[QNTabBarViewController alloc]init];
        UIWindow *window =  [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        window.rootViewController = tabBarVc;
    }
    
    [self.AVPlayer.player pause];
    
}
@end
