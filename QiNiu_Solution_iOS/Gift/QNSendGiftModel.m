//
//  QNSendGiftModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNSendGiftModel.h"

@implementation QNSendGiftModel

- (NSString *)giftKey {
    return [NSString stringWithFormat:@"%@%@",self.giftName,self.giftId];
}

@end
