//
//  LDRoomInfoViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDRoomInfoViewController.h"

@interface LDRoomInfoViewController ()
@property (nonatomic, assign) CGFloat presetKeyboardHeight;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextField *editor;
@property (nonatomic, strong) UIButton *beginButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation LDRoomInfoViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _container = ({
        UIView *container = [[UIView alloc] init];
        [self.view addSubview:container];
        container;
    });
    _editor = ({
        UITextField *editor = [[UITextField alloc] init];
        [_container addSubview:editor];
        [editor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(_container);
        }];
        editor;
    });
    _beginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_container addSubview:button];
        [button setTitle:@"Begin Broadcasting" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(_onPressedBeginBroadcastingButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_container);
            make.bottom.equalTo(_container).with.offset(-kBeginBroadingButtonFloatHeight);
        }];
        button;
    });
    _closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_container addSubview:button];
        [button setTitle:@"Close" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(_onPressedCloseButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_container).with.offset(25);
            make.right.equalTo(_container).with.offset(-25);
        }];
        button;
    });
    [self addNotifications];
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

- (void)addNotifications
{
    NSNotificationCenter *notificationCenger = [NSNotificationCenter defaultCenter];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWasShown:)
                               name:UIKeyboardWillShowNotification object:nil];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWillBeHidden:)
                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)clearNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)_onPressedCloseButton:(UIButton *)button
{
    [self _responseTitle:nil];
}

- (void)_onPressedBeginBroadcastingButton:(UIButton *)button
{
    NSString *title = [self standardizeTitle:self.editor.text];
    if ([self isTilteBlank:title]) {
        [self.view makeToast:LDString("please-input-any-messages-as_broadcasting-title")
                    duration:1.2 position:CSToastPositionTop];
    } else {
        [self _responseTitle:title];
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
