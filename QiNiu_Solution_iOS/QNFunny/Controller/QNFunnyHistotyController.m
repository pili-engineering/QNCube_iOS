//
//  QNFunnyHistotyController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/5/6.
//

#import "QNFunnyHistotyController.h"
#import <PLPlayerKit/PLPlayerKit.h>

@interface QNFunnyHistotyController ()<
PLPlayerDelegate
>

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation QNFunnyHistotyController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.title = [self.model.userId stringByAppendingString:@"的直播"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self playWithUrlStr:self.model.playUrl];
    
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
}

// 退出房间
- (void)conference {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
