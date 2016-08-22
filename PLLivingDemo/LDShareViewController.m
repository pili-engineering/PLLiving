//
//  LDShareViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/29.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDShareViewController.h"
#import "LDPanGestureHandler.h"
#import "LDRoomItem.h"

@interface LDShareViewController ()
@property (nonatomic, assign) BOOL didClosed;
@property (nonatomic, strong) LDRoomItem *roomItem;
@property (nonatomic, strong) UIButton *shareToFriendsButton;
@property (nonatomic, strong) UIButton *shareToTimelineButton;
@property (nonatomic, strong) UIButton *shareURLButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation LDShareViewController

- (instancetype)initWithPresentOrientation:(LDBlurViewControllerPresentOrientation)presentOrientation
                              withRoomItem:(LDRoomItem *)roomItem
{
    if (self = [self initWithPresentOrientation:presentOrientation]) {
        _roomItem = roomItem;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *container = ({
        UIView *view = [[UIView alloc] init];
        [self.view addSubview:view];
        view.backgroundColor = [UIColor colorWithHexString:@"010101"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(153);
        }];
        view;
    });
    
    UIView *leftArea = ({
        UIView *view = [[UIView alloc] init];
        [container addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(container);
            make.left.equalTo(container);
            make.right.equalTo(container.mas_centerX);
        }];
        view;
    });
    UIView *rightArea = ({
        UIView *view = [[UIView alloc] init];
        [container addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(container);
            make.left.equalTo(container.mas_centerX);
            make.right.equalTo(container);
        }];
        view;
    });
    
    self.shareToFriendsButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [container addSubview:button];
        [button setImage:[UIImage imageNamed:@"share-wechat"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).with.offset(48);
            make.centerX.equalTo(leftArea);
        }];
        button;
    });
    
    self.shareToTimelineButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [container addSubview:button];
        [button setImage:[UIImage imageNamed:@"share-moment"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).with.offset(48);
            make.centerX.equalTo(container);
        }];
        button;
    });
    
    self.shareURLButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [container addSubview:button];
        [button setImage:[UIImage imageNamed:@"share-link"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).with.offset(48);
            make.centerX.equalTo(rightArea);
        }];
        button;
    });
    
    self.cancelButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [container addSubview:button];
        [button setTitleColor:[UIColor colorWithHexString:@"B8B8B8"] forState:UIControlStateNormal];
        [button setTitle:LDString("cancel") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(container).with.offset(-16);
            make.centerX.equalTo(container);
        }];
        button;
    });
    
    __weak typeof(self) weakSelf = self;
    [LDPanGestureHandler handleView:self.view orientation:LDPanGestureHandlerOrientation_Down strengthRate:1.0 recognized:^{
        [weakSelf close];
    }];
    [self.shareToFriendsButton addTarget:self action:@selector(_pressedShareToFriendsButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.shareToTimelineButton addTarget:self action:@selector(_pressedShareToTimelineButton:)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.shareURLButton addTarget:self action:@selector(_pressedShareURLButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(_pressedCancelButton:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)_pressedShareToFriendsButton:(id)sender
{
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;
    sendReq.scene = WXSceneSession;
    
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = @"LIVING 七牛直播测试内容";
    [urlMessage setThumbImage:[UIImage imageNamed:@"logo"]];
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = [self _generateURL];
    
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    [WXApi sendReq:sendReq];
}

- (void)_pressedShareToTimelineButton:(id)sender
{
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;
    sendReq.scene = WXSceneTimeline;
    
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = @"LIVING 七牛直播测试内容";
    [urlMessage setThumbImage:[UIImage imageNamed:@"logo"]];
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = [self _generateURL];
    
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    [WXApi sendReq:sendReq];
}

- (void)_pressedShareURLButton:(id)sender
{
    
    [[UIPasteboard generalPasteboard] setString:[self _generateURL]];
}

- (void)_pressedCancelButton:(id)sender
{
    [self close];
}

- (NSString *)_generateURL
{
    NSString *flvURL = self.roomItem.flvPlayURL;
    NSString *m3u8URL = self.roomItem.m3u8PlayURL;
    NSString *poster = self.roomItem.previewURL;
    return [NSString stringWithFormat:@"http://www.qiniu.com?flv=%@&m3u8=%@&poster=%@", flvURL, m3u8URL, poster];
}

- (void)close
{
    if (!self.didClosed) {
        self.didClosed = YES;
        [self.basicViewController removeViewController:self animated:NO completion:nil];
        [self playDisappearAnimationWithComplete:nil];
    }
}

@end
