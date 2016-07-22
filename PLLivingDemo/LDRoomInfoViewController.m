//
//  LDRoomInfoViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDRoomInfoViewController.h"
#import "LDViewConstraintsStateManager.h"

@interface LDRoomInfoViewController ()
@property (nonatomic, assign) CGFloat presetKeyboardHeight;
@property (nonatomic, strong) LDViewConstraintsStateManager *constraints;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextView *editor;
@property (nonatomic, strong) UIButton *beginButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

typedef enum {
    LayoutState_Show,
    LayoutState_Hide
} LayoutState;

@implementation LDRoomInfoViewController

- (instancetype)init
{
    if (self = [super init]) {
        _constraints = [[LDViewConstraintsStateManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.container = ({
        UIView *container = [[UIView alloc] init];
        [self.view addSubview:container];
        container;
    });
    self.editor = ({
        UITextView *editor = [[UITextView alloc] init];
        [self.container addSubview:editor];
        [editor setEditable:YES];
        [editor setFont:[UIFont systemFontOfSize:18]];
        [editor setTintColor:[UIColor whiteColor]];
        [editor setTextColor:[UIColor whiteColor]];
        [editor setBackgroundColor:[UIColor clearColor]];
        [editor setKeyboardAppearance:UIKeyboardAppearanceAlert];
        [editor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).with.offset(78);
            make.left.equalTo(self.container).with.offset(50);
            make.bottom.equalTo(self.container).with.offset(-78);
            make.right.equalTo(self.container).with.offset(-50);
        }];
        editor;
    });
    self.beginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.container addSubview:button];
        [button setTitle:@"Begin Broadcasting" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithHexString:@"ED5757"];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.cornerRadius = 22;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.container);
            make.size.mas_equalTo(CGSizeMake(260, 44));
        }];
        [button addTarget:self action:@selector(_onPressedBeginBroadcastingButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.container addSubview:button];
        [button setImage:[UIImage imageNamed:@"icon-big-close"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.container).with.offset(-22.1);
        }];
        [button addTarget:self action:@selector(_onPressedCloseButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    __weak typeof(self) weakSelf = self;
    
    [self.constraints addState:@(LayoutState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.beginButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 1;
            make.bottom.equalTo(weakSelf.container).with.offset(-22);
        }];
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 1;
            make.top.equalTo(weakSelf.container).with.offset(21.1);
        }];
    }];
    
    [self.constraints addState:@(LayoutState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.beginButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 0;
            make.top.equalTo(weakSelf.container.mas_bottom);
        }];
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 0;
            make.bottom.equalTo(weakSelf.container.mas_top);
        }];
    }];
    
    self.constraints.state = @(LayoutState_Hide);
    [UIView animateWithDuration:0.5 animations:^{
        self.constraints.state = @(LayoutState_Show);
    }];
    
    [self _addNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.editor becomeFirstResponder];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGSize size = self.view.bounds.size;
    self.container.frame = CGRectMake(0, 0, size.width, size.height - self.presetKeyboardHeight);
}

- (void)_addNotifications
{
    NSNotificationCenter *notificationCenger = [NSNotificationCenter defaultCenter];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWasShown:)
                               name:UIKeyboardWillShowNotification object:nil];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWillBeHidden:)
                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)_onFoundKeyboardWasShown:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.presetKeyboardHeight = MIN(keyboardFrame.size.width, keyboardFrame.size.height);
    [UIView animateWithDuration:duration animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void)_onFoundKeyboardWillBeHidden:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.presetKeyboardHeight = 0;
    [UIView animateWithDuration:duration animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void)closeRoomInfoViewController
{
    [self _closeWithAnimationFinish:nil];
}

- (void)_closeWithAnimationFinish:(void (^)())finishBlock
{
    [self.editor resignFirstResponder];
    [self.editor setEditable:NO];
    
    self.constraints.state = @(LayoutState_Show);
    [UIView animateWithDuration:0.35 animations:^{
        self.constraints.state = @(LayoutState_Hide);
        self.editor.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (finishBlock) {
            finishBlock();
        }
    }];
}

- (void)_onPressedCloseButton:(UIButton *)button
{
    [self _closeWithAnimationFinish:nil];
    [self _responseTitle:nil];
}

- (void)_onPressedBeginBroadcastingButton:(UIButton *)button
{
    NSString *title = [self standardizeTitle:self.editor.text];
    if ([self isTilteBlank:title]) {
        [self.view makeToast:LDString("please-input-any-messages-as_broadcasting-title")
                    duration:1.2 position:CSToastPositionTop];
    } else {
        [self _closeWithAnimationFinish:^{
            [self _responseTitle:title];
        }];
    }
}

- (void)_responseTitle:(NSString *)title
{
    if ([self.delegate respondsToSelector:@selector(onReciveRoomInfoWithTitle:)]) {
        [self.delegate performSelector:@selector(onReciveRoomInfoWithTitle:) withObject:title];
    }
}

- (NSString *)standardizeTitle:(NSString *)title
{
    if (title) {
        title = [title stringByReplacingOccurrencesOfRegex:@"(^\\s+|\\s+$)" withString:@""];
        title = [title stringByReplacingOccurrencesOfRegex:@"\\n+" withString:@" "];
    }
    return title;
}

- (BOOL)isTilteBlank:(NSString *)title
{
    return !title || [title isMatchedByRegex:@"^\\s*$"];
}

@end
