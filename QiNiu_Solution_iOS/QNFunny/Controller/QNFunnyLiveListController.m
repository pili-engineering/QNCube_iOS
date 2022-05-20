//
//  QNFunnyLiveListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/5/6.
//

#import "QNFunnyLiveListController.h"
#import "QNRoomRequest.h"
#import "QNLiveRecordModel.h"
#import "QNFunnyListCell.h"
#import "QNFunnyHistotyController.h"

@interface QNFunnyLiveListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <QNLiveRecordModel *> *list;

@end

@implementation QNFunnyLiveListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self collectionView];
    [self requestData];
}

- (void)requestData {
    
    QNRoomRequest *request = [[QNRoomRequest alloc]initWithType:@"show" roomId:@""];
    [request getLiveCodeSuccess:^(NSArray<QNLiveRecordModel *> * _Nonnull list) {
        self.list = list;
        
        [self.collectionView reloadData];
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNFunnyListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNFunnyListCell" forIndexPath:indexPath];
    [cell updateWithRecordModel:self.list[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
    QNFunnyHistotyController *vc = [QNFunnyHistotyController new];
    vc.model = self.list[indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
   
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
