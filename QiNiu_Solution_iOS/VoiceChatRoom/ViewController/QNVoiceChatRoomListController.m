//
//  QNVoiceChatRoomListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNVoiceChatRoomListController.h"
#import <YYCategories/YYCategories.h>
#import "QNFunnyListCell.h"
#import "QNVoiceChatRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNNetworkUtil.h"
#import "QNRoomDetailModel.h"
#import <MJExtension/MJExtension.h>
#import "AlertViewController.h"

@interface QNVoiceChatRoomListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) QNRoomDetailModel *model;

@property (nonatomic, strong) NSArray <QNRoomInfo *> *rooms;

@end

@implementation QNVoiceChatRoomListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"房间列表";
    [self collectionView];
    [self requestData];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_increase"] style:UIBarButtonItemStyleDone target:self action:@selector(addRoom)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)requestData {
        
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"type"] = @"voiceChatRoom";
    
    [QNNetworkUtil getRequestWithAction:@"base/listRoom" params:requestParams success:^(NSDictionary *responseData) {
            
        self.rooms = [QNRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        [self.collectionView reloadData];
        
        } failure:^(NSError *error) {
            
        }];
}

- (void)addRoom {
    
    [AlertViewController showTextAlertWithTitle:@"设置房间名" content:@"" cancelHandler:^(UIAlertAction * _Nonnull action) {
            
    } confirmHandler:^(NSString * _Nonnull text) {
        [self startRoomWithName:text];
    }];

}

- (void)startRoomWithName:(NSString *)name {
        
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"title"] = name;
    requestParams[@"type"] = @"voiceChatRoom";
    
    [QNNetworkUtil postRequestWithAction:@"base/createRoom" params:requestParams success:^(NSDictionary *responseData) {
        
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        model.roomType = QN_Room_Type_VoiceChatRoom;
        model.userInfo.role = @"roomHost";
        QNVoiceChatRoomController *vc = [[QNVoiceChatRoomController alloc]initWithRoomModel:model];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
            
        } failure:^(NSError *error) {
            [MBProgressHUD showText:@"创建房间失败"];
        }];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rooms.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNFunnyListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNFunnyListCell" forIndexPath:indexPath];
    [cell updateWithModel:self.rooms[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QNRoomDetailModel *model = [QNRoomDetailModel new];
    model.roomType = QN_Room_Type_VoiceChatRoom;
    model.roomInfo = self.rooms[indexPath.item];
    QNUserInfo *userInfo = [QNUserInfo new];
    userInfo.role = @"roomAudience";
    model.userInfo = userInfo;
    
    QNVoiceChatRoomController *vc = [[QNVoiceChatRoomController alloc]initWithRoomModel:model];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 15)/2, (kScreenWidth - 15)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth - 5, self.view.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QNFunnyListCell class] forCellWithReuseIdentifier:@"QNFunnyListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
