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
@property (nonatomic, strong) UITextField *editor;
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
        UITextField *editor = [[UITextField alloc] init];
        [self.container addSubview:editor];
        [editor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.container);
        }];
        editor;
    });
    self.beginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.container addSubview:button];
        [button setTitle:@"Begin Broadcasting" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(_onPressedBeginBroadcastingButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.container addSubview:button];
        [button setTitle:@"Close" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(_onPressedCloseButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    __weak typeof(self) weakSelf = self;
    
    [self.constraints addState:@(LayoutState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.beginButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 1;
            make.centerX.equalTo(weakSelf.container);
            make.bottom.equalTo(weakSelf.container).with.offset(-kBeginBroadingButtonFloatHeight);
        }];
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 1;
            make.right.equalTo(weakSelf.container).with.offset(-25);
            make.top.equalTo(weakSelf.container).with.offset(25);
        }];
    }];
    
    [self.constraints addState:@(LayoutState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.beginButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 0;
            make.centerX.equalTo(weakSelf.container);
            make.top.equalTo(weakSelf.container.mas_bottom);
        }];
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 0;
            make.right.equalTo(weakSelf.container).with.offset(-25);
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

- (void)_onPressedCloseButton:(UIButton *)button
{
    self.constraints.state = @(LayoutState_Show);
    [UIView animateWithDuration:0.5 animations:^{
        self.constraints.state = @(LayoutState_Hide);
    }];
    [self.editor resignFirstResponder];
    [self.editor setEnabled:NO];
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
