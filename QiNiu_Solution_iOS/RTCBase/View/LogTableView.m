//
//  LogTableView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/4/8.
//

#import "LogTableView.h"

@implementation LogTableView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        if (self.numberOfSections && [self numberOfRowsInSection:0]) {
            if (self.isScrolling) return;
            if (!self.isBottom) return;
            if (_lastCount == [self numberOfRowsInSection:0]) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self numberOfRowsInSection:0] - 1 inSection:0];
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
            _lastCount = [self numberOfRowsInSection:0];
        }
    }
}

@end
