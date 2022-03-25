//
//  QNBottomOperationView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/23.
//

#import "QNVoiceChatBottomOperationView.h"

@interface QNVoiceChatBottomOperationView ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *commentTf;

@end

@implementation QNVoiceChatBottomOperationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self commentTf];
        
        UIView *rightView = [[UIView alloc]init];
        [self addSubview:rightView];
        CGFloat rightViewWidth = kScreenWidth - kScreenWidth/2 - 15;
        
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.commentTf);
            make.left.equalTo(self.commentTf.mas_right);
            make.width.mas_equalTo(rightViewWidth);
            make.height.mas_equalTo(40);
        }];
        
        NSString *selectedImage[] = {@"icon_gift",@"icon_microphone_on", @"icon_quit_show"};
        NSString *normalImage[] = {@"icon_gift",@"icon_microphone_off",@"icon_quit_show"};
        SEL selectors[] = {@selector(giftAction),@selector(microphoneAction:),@selector(quitRoom)};
        CGFloat buttonWidth = 40;
        NSInteger space = (rightViewWidth - buttonWidth * ARRAY_SIZE(normalImage))/(ARRAY_SIZE(normalImage)+1);
        
        for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:selectedImage[i]] forState:(UIControlStateSelected)];
            [button setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
            [button addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
            button.selected = YES;
            [rightView addSubview:button];
        }
        
        [rightView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
        [rightView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(buttonWidth);
        }];
    }
    return self;
    
}

- (void)giftAction {
    if (self.giftBlock) {
        self.giftBlock();
    }
}

- (void)microphoneAction:(UIButton *)button {
    button.selected = !button.isSelected;
    if (self.microphoneBlock) {
        self.microphoneBlock(button.selected);
    }
}

- (void)quitRoom {
    if (self.quitBlock) {
        self.quitBlock();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (self.textBlock) {
        self.textBlock(textField.text);
    }
    
    [self.commentTf resignFirstResponder];
    self.commentTf.text = @"";
    
}

- (UITextField *)commentTf {
    if (!_commentTf) {
        _commentTf = [[UITextField alloc]initWithFrame:CGRectZero];
        _commentTf.backgroundColor = [UIColor blackColor];
        _commentTf.alpha = 0.5;
        _commentTf.delegate = self;
        _commentTf.font = [UIFont systemFontOfSize:14];
        _commentTf.layer.cornerRadius = 10;
        _commentTf.clipsToBounds = YES;
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"  说点什么..." attributes:
             @{NSForegroundColorAttributeName:[UIColor whiteColor],
               NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _commentTf.attributedPlaceholder = attrString;
        _commentTf.textColor = [UIColor whiteColor];
        [self addSubview:_commentTf];
        
        [_commentTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(kScreenWidth/2);
        }];
        
    }
    return _commentTf;
}

@end
