//
//  LDDevicePermissionManager.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDDevicePermissionManager.h"

@interface LDDevicePermissionManager ()
@property (nonatomic, strong) void (^completeBlock)(BOOL granted);
@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, assign) BOOL cameraDenied;
@property (nonatomic, assign) BOOL microphoneDenied;
@property (nonatomic, assign) PLAuthorizationStatus cameraStatus;
@property (nonatomic, assign) PLAuthorizationStatus microphoneStatus;
@end

@implementation LDDevicePermissionManager

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController
                                withComplete:(void (^)(BOOL success))completeBlock
{
    if (self = [self init]) {
        _parentViewController = parentViewController;
        _completeBlock = completeBlock;
    }
    return self;
}

+ (void)requestDevicePermissionWithParentViewController:(UIViewController *)parentViewController
                                           withComplete:(void (^)(BOOL success))completeBlock
{
    LDDevicePermissionManager *manager;
    manager = [[LDDevicePermissionManager alloc] initWithParentViewController:parentViewController
                                                                 withComplete:completeBlock];
    [manager _checkAndRequestPermission];
}

- (void)_checkAndRequestPermission
{
    self.cameraDenied = NO;
    self.microphoneDenied = NO;
    self.cameraStatus = [PLCameraStreamingSession cameraAuthorizationStatus];
    self.microphoneStatus = [PLCameraStreamingSession microphoneAuthorizationStatus];
    
    if (self.cameraStatus == PLAuthorizationStatusNotDetermined) {
        [self _requestCameraAuthorization];
        
    } else if (self.microphoneStatus == PLAuthorizationStatusNotDetermined) {
        [self _requestMicrophonAuthorization];
        
    } else {
        [self _handleAuthorizationStatusResult];
    }
}

- (void)_requestCameraAuthorization
{
    [PLCameraStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
        // ［特别注意］这个回调并不在 Main 线程中，如果此回调存在 UI 操作，请务必转到 Main 线程中处理。
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraStatus = granted? PLAuthorizationStatusAuthorized: PLAuthorizationStatusDenied;
            if (!granted) {
                self.cameraDenied = YES;
            }
            if (granted && self.microphoneStatus == PLAuthorizationStatusNotDetermined) {
                [self _requestMicrophonAuthorization];
            } else {
                [self _handleAuthorizationStatusResult];
            }
        });
    }];
}

- (void)_requestMicrophonAuthorization
{
    [PLCameraStreamingSession requestMicrophoneAccessWithCompletionHandler:^(BOOL granted) {
        // ［特别注意］：这个回调并不在 Main 线程中，如果此回调存在 UI 操作，请务必转到 Main 线程中处理。
        dispatch_async(dispatch_get_main_queue(), ^{
            self.microphoneStatus = granted? PLAuthorizationStatusAuthorized: PLAuthorizationStatusDenied;
            if (!granted) {
                self.microphoneDenied = YES;
            }
            [self _handleAuthorizationStatusResult];
        });
    }];
}

- (void)_handleAuthorizationStatusResult
{
    if (self.cameraDenied) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("camera-permission-denied")];
        
    } else if (self.microphoneDenied) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("microphone-permission-denied")];
        
    } else if (self.cameraStatus == PLAuthorizationStatusDenied) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("camera-permission-did-denied")];
        
    } else if (self.microphoneStatus == PLAuthorizationStatusDenied) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("microphone-permission-did-denied")];
        
    } else if (self.cameraStatus == PLAuthorizationStatusRestricted) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("camera-restricted")];
        
    } else if (self.microphoneStatus == PLAuthorizationStatusRestricted) {
        [self _alertAndDeclareFailWithErrorMessage:LDString("microphone-restricted")];
        
    } else {
        self.completeBlock(YES);
    }
}

- (void)_alertAndDeclareFailWithErrorMessage:(NSString *)errorMessage
{
    UIAlertController *av = [UIAlertController alertControllerWithTitle:LDString("can-not-broadcasting")
                                                                message:errorMessage
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [av addAction:[UIAlertAction actionWithTitle:LDString("I-see")
                                           style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             self.completeBlock(NO);
                                         }]];
    [self.parentViewController presentViewController:av animated:true completion:nil];
}

@end
