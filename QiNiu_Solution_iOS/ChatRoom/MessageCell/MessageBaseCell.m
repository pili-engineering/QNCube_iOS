//
//  MessageBaseCell.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "MessageBaseCell.h"

@implementation MessageBaseCell

- (void)setDataModel:(QNIMMessageObject *)model {
    self.model = model;
    [self setBaseAutoLayout];
}

- (void)setBaseAutoLayout {
 
}

@end
